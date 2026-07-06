import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_profile_provider.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_online_status_provider.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_tracking_provider.dart';
import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart'
    show VerificationStatus;

class RideOnlineToggle extends ConsumerWidget {
  final String driverId;

  const RideOnlineToggle({super.key, required this.driverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(rideDriverProfileProvider).asData?.value;
    final isApproved =
        driver?.verificationStatus == VerificationStatus.approved;
    final isTracking = ref.watch(rideTrackingProvider).isTracking;
    final isToggling = ref.watch(rideOnlineStatusProvider).isLoading;
    final controller = ref.read(rideOnlineStatusProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTracking ? AppColors.successBg : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTracking
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTracking
                ? Icons.location_on_rounded
                : Icons.location_off_outlined,
            color: isTracking ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTracking ? "You're Online" : "You're Offline",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!isApproved)
                  const Text(
                    'Approval is required before you can go online.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: isTracking,
            onChanged: (isApproved && !isToggling)
                ? (_) => controller.toggle(driverId)
                : null,
            activeThumbColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}
