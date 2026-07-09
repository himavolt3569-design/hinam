import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/hinam_ride/pricing/presentation/providers/suggested_fare_provider.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/providers/active_ride_provider.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/providers/matching_service_provider.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/providers/ride_request_controller.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/widgets/pickup_dropoff_picker.dart';
import 'package:hinam/shared/widgets/loading_button.dart';

class RideRequestScreen extends ConsumerStatefulWidget {
  const RideRequestScreen({super.key});

  @override
  ConsumerState<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends ConsumerState<RideRequestScreen> {
  RideLocation? _pickup;
  RideLocation? _dropoff;

  Future<void> _requestRide(String passengerId) async {
    final pickup = _pickup;
    final dropoff = _dropoff;

    if (pickup == null || dropoff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both pickup and drop-off points.'),
        ),
      );
      return;
    }

    final suggestedFare = ref.read(
      suggestedFareProvider((pickup: pickup, dropoff: dropoff)),
    );

    await ref
        .read(rideRequestControllerProvider.notifier)
        .createRide(
          passengerId: passengerId,
          pickup: pickup,
          dropoff: dropoff,
          suggestedFare: suggestedFare,
        );

    if (!mounted) return;
    final error = ref.read(rideRequestControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _cancelRide(String rideId) async {
    await ref.read(rideRequestControllerProvider.notifier).cancelRide(rideId);
  }

  @override
  Widget build(BuildContext context) {
    // Kept alive for as long as this screen is mounted, so the matching
    // service's offer-escalation timer isn't disposed prematurely.
    ref.watch(matchingServiceProvider);

    final user = ref.read(authControllerProvider.notifier).currentUser();
    final requestState = ref.watch(rideRequestControllerProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('You must be signed in to book a ride.')),
      );
    }

    final activeRideAsync = ref.watch(activeRideProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Book a Ride')),
      body: activeRideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (activeRide) {
          if (activeRide != null) {
            return _buildActiveRideView(activeRide, requestState.isLoading);
          }
          return _buildRequestForm(user.uid, requestState.isLoading);
        },
      ),
    );
  }

  Widget _buildRequestForm(String passengerId, bool isSaving) {
    final pickup = _pickup;
    final dropoff = _dropoff;
    final suggestedFare = (pickup != null && dropoff != null)
        ? ref.watch(suggestedFareProvider((pickup: pickup, dropoff: dropoff)))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PickupDropoffPicker(
            pickup: _pickup,
            dropoff: _dropoff,
            onPickupChanged: (location) => setState(() => _pickup = location),
            onDropoffChanged: (location) =>
                setState(() => _dropoff = location),
          ),

          const SizedBox(height: 20),

          if (suggestedFare != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Suggested Fare',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Rs. ${suggestedFare.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          LoadingButton(
            text: 'Request Ride',
            isLoading: isSaving,
            onPressed: () => _requestRide(passengerId),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRideView(RideModel ride, bool isCancelling) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.status == RideStatus.matched
                      ? 'Driver Assigned!'
                      : 'Looking for a driver…',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _LocationRow(
                  icon: Icons.trip_origin_rounded,
                  color: AppColors.success,
                  label: ride.pickup.address,
                ),
                const SizedBox(height: 8),
                _LocationRow(
                  icon: Icons.location_on_rounded,
                  color: AppColors.error,
                  label: ride.dropoff.address,
                ),
                const SizedBox(height: 12),
                Text(
                  ride.status == RideStatus.matched
                      ? 'Agreed Fare: Rs. ${(ride.agreedFare ?? ride.suggestedFare).toStringAsFixed(0)}'
                      : 'Suggested Fare: Rs. ${ride.suggestedFare.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (ride.status == RideStatus.requested)
            OutlinedButton.icon(
              onPressed: isCancelling ? null : () => _cancelRide(ride.id),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text(isCancelling ? 'Cancelling…' : 'Cancel Request'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _LocationRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
