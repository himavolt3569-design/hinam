import 'package:flutter/material.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

class BusListCard extends StatelessWidget {
  final BusLocationModel bus;
  final VoidCallback onTap;

  const BusListCard({super.key, required this.bus, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bus.busNumber,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  if (bus.routeName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      bus.routeName!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        bus.driverName.isEmpty ? 'Driver' : bus.driverName,
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${bus.speed.toStringAsFixed(0)} km/h',
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
