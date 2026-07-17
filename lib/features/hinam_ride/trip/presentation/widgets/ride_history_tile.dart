import 'package:flutter/material.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';

class RideHistoryTile extends StatelessWidget {
  final RideModel ride;
  final bool isDriver;

  const RideHistoryTile({
    super.key,
    required this.ride,
    required this.isDriver,
  });

  @override
  Widget build(BuildContext context) {
    final ownRating = isDriver ? ride.passengerRating : ride.driverRating;
    final date = ride.createdAt.toDate();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              _StatusBadge(status: ride.status),
            ],
          ),
          const SizedBox(height: 10),
          _LocationRow(
            icon: Icons.trip_origin_rounded,
            color: AppColors.success,
            label: ride.pickup.address,
          ),
          const SizedBox(height: 6),
          _LocationRow(
            icon: Icons.location_on_rounded,
            color: AppColors.error,
            label: ride.dropoff.address,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Rs. ${(ride.agreedFare ?? ride.suggestedFare).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (ownRating != null) ...[
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 2),
                Text(
                  ownRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final RideStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      RideStatus.completed => (
        'Completed',
        AppColors.success,
        AppColors.successBg,
      ),
      RideStatus.cancelled => ('Cancelled', AppColors.error, AppColors.errorBg),
      RideStatus.noShow => ('No-Show', AppColors.warning, AppColors.warningBg),
      _ => ('In Progress', AppColors.primary, AppColors.primaryBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
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
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
