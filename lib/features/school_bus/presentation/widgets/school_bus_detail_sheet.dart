import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/eta/presentation/providers/eta_provider.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

class SchoolBusDetailSheet extends ConsumerWidget {
  final BusLocationModel bus;

  const SchoolBusDetailSheet({super.key, required this.bus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.green.shade700,
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
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'School Bus · Active',
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
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          if (bus.schoolName != null) ...[
            _InfoRow(
              icon: Icons.location_city_outlined,
              label: 'School',
              value: bus.schoolName!,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 12),
          ],

          _InfoRow(
            icon: Icons.people_rounded,
            label: 'Students on board',
            value:
                '${bus.studentCount} student${bus.studentCount != 1 ? 's' : ''}',
            color: scheme.primary,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.speed_rounded,
            label: 'Speed',
            value: '${(bus.speed * 3.6).toStringAsFixed(1)} km/h',
            color: scheme.primary,
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
            _InfoRow(
              icon: Icons.signpost_rounded,
              label: nearestStop.stop.name,
              value: nearestStop.formattedDistance,
              color: const Color(0xFFEA580C),
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.access_time_rounded,
              label: 'ETA to stop',
              value: nearestStop.formattedEta,
              color: const Color(0xFFEA580C),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: text.labelSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45),
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                value,
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
