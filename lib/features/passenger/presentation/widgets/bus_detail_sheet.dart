import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/eta/presentation/providers/eta_provider.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';
import 'map_info_row.dart';

class BusDetailSheet extends ConsumerWidget {
  final BusLocationModel bus;

  const BusDetailSheet({super.key, required this.bus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isPublic = bus.busType == 'public';
    final routeOrSchool = bus.routeName ?? bus.schoolName;
    final nearestStop = ref.watch(busNearestStopProvider(bus.driverId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPublic
                      ? Icons.directions_bus_rounded
                      : Icons.school_rounded,
                  color: scheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.busNumber,
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Active now',
                          style: text.bodySmall?.copyWith(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPublic ? 'Public' : 'School',
                  style: text.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          if (routeOrSchool != null) ...[
            MapInfoRow(
              icon: isPublic
                  ? Icons.route_outlined
                  : Icons.location_city_outlined,
              label: isPublic ? 'Route' : 'School',
              value: routeOrSchool,
            ),
            const SizedBox(height: 12),
          ],

          MapInfoRow(
            icon: Icons.speed_rounded,
            label: 'Speed',
            value: '${(bus.speed * 3.6).toStringAsFixed(1)} km/h',
          ),
          const SizedBox(height: 12),
          MapInfoRow(
            icon: Icons.my_location_rounded,
            label: 'Position',
            value:
                '${bus.latitude.toStringAsFixed(4)}, ${bus.longitude.toStringAsFixed(4)}',
          ),

          if (nearestStop != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'NEAREST STOP',
              style: text.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            MapInfoRow(
              icon: Icons.signpost_rounded,
              label: nearestStop.stop.name,
              value: nearestStop.formattedDistance,
              iconColor: const Color(0xFFEA580C),
            ),
            const SizedBox(height: 10),
            MapInfoRow(
              icon: Icons.access_time_rounded,
              label: 'ETA to stop',
              value: nearestStop.formattedEta,
              iconColor: const Color(0xFFEA580C),
            ),
          ],
        ],
      ),
    );
  }
}
