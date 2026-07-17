import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/widgets/report_form_dialog.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/providers/active_ride_provider.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/providers/cancellation_controller.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/widgets/cancel_ride_dialog.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/widgets/driver_identity_card.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/widgets/no_show_banner.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/widgets/ride_location_marker.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/widgets/trip_ended_view.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/widgets/trip_status_bar.dart';

class RideTrackingScreen extends ConsumerWidget {
  final String rideId;

  const RideTrackingScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideAsync = ref.watch(rideByIdProvider(rideId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Your Trip')),
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (ride) {
          if (ride == null) {
            return const Center(child: Text('This ride no longer exists.'));
          }
          return _TripBody(ride: ride);
        },
      ),
    );
  }
}

class _TripBody extends ConsumerWidget {
  final RideModel ride;

  const _TripBody({required this.ride});

  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => CancelRideDialog(
        reasonRequired: ride.status == RideStatus.inProgress,
        onConfirm: (reason) async {
          await ref
              .read(cancellationControllerProvider.notifier)
              .cancel(
                rideId: ride.id,
                cancelledBy: ride.passengerId,
                cancelReason: reason,
              );
          if (!context.mounted) return;
          final error = ref.read(cancellationControllerProvider).error;
          if (error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.toString())));
          }
        },
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          ReportFormDialog(rideId: ride.id, reportedUserId: ride.driverId!),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ride.status == RideStatus.completed ||
        ride.status == RideStatus.cancelled ||
        ride.status == RideStatus.noShow) {
      return TripEndedView(ride: ride, isDriver: false);
    }

    final pickup = LatLng(ride.pickup.latitude, ride.pickup.longitude);
    final dropoff = LatLng(ride.dropoff.latitude, ride.dropoff.longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: TripStatusBar(status: ride.status),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            child: FlutterMap(
              options: MapOptions(initialCenter: pickup, initialZoom: 13.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hinam.app',
                ),
                MarkerLayer(
                  markers: [
                    buildRideLocationMarker(
                      pickup,
                      AppColors.success,
                      Icons.trip_origin_rounded,
                    ),
                    buildRideLocationMarker(
                      dropoff,
                      AppColors.error,
                      Icons.location_on_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (ride.driverId != null)
                DriverIdentityCard(driverId: ride.driverId!),
              if (ride.status == RideStatus.arrived) ...[
                const SizedBox(height: 12),
                NoShowBanner(ride: ride, canMarkNoShow: false),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              if (ride.driverId != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReportDialog(context),
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: const Text('Report'),
                  ),
                ),
              if (ride.driverId != null) const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, ref),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Cancel Ride'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
