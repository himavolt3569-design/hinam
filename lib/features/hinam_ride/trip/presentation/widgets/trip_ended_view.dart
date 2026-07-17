import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/widgets/report_form_dialog.dart';
import 'package:hinam/features/hinam_ride/payments/presentation/widgets/mark_paid_button.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/providers/rating_controller.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/widgets/rating_prompt.dart';

class TripEndedView extends ConsumerWidget {
  final RideModel ride;
  final bool isDriver;

  const TripEndedView({super.key, required this.ride, required this.isDriver});

  Future<void> _submitRating(
    BuildContext context,
    WidgetRef ref,
    double rating,
    String? comment,
  ) async {
    await ref
        .read(ratingControllerProvider.notifier)
        .submitRating(
          rideId: ride.id,
          isDriver: isDriver,
          rating: rating,
          comment: comment,
        );

    if (!context.mounted) return;
    final error = ref.read(ratingControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = ride.status == RideStatus.completed;
    final ownRatingGiven = isDriver ? ride.passengerRating : ride.driverRating;
    final ratingState = ref.watch(ratingControllerProvider);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 48, color: _color),
            const SizedBox(height: 16),
            Text(
              _title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (!isCompleted && ride.cancelReason != null) ...[
              const SizedBox(height: 8),
              Text(
                ride.cancelReason!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (isCompleted) ...[
              const SizedBox(height: 8),
              Text(
                'Fare: Rs. ${(ride.agreedFare ?? ride.suggestedFare).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              MarkPaidButton(
                rideId: ride.id,
                payerId: ride.passengerId,
                payeeId: ride.driverId!,
                amount: ride.agreedFare ?? ride.suggestedFare,
              ),
              const SizedBox(height: 20),
              if (ownRatingGiven == null)
                RatingPrompt(
                  title: isDriver ? 'Rate Your Passenger' : 'Rate Your Driver',
                  isSubmitting: ratingState.isLoading,
                  onSubmit: (rating, comment) =>
                      _submitRating(context, ref, rating, comment),
                )
              else
                Text(
                  'Thanks for rating this trip.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
            if (ride.driverId != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => ReportFormDialog(
                    rideId: ride.id,
                    reportedUserId: isDriver
                        ? ride.passengerId
                        : ride.driverId!,
                  ),
                ),
                icon: const Icon(Icons.flag_outlined, size: 16),
                label: const Text('Report an Issue'),
              ),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    if (ride.status == RideStatus.completed) return Icons.check_circle_rounded;
    if (ride.status == RideStatus.noShow) return Icons.person_off_rounded;
    return Icons.cancel_rounded;
  }

  Color get _color {
    if (ride.status == RideStatus.completed) return AppColors.success;
    if (ride.status == RideStatus.noShow) return AppColors.warning;
    return AppColors.error;
  }

  String get _title {
    if (ride.status == RideStatus.completed) return 'Trip Completed';
    if (ride.status == RideStatus.noShow) return 'Passenger Did Not Show Up';
    return 'Trip Cancelled';
  }
}
