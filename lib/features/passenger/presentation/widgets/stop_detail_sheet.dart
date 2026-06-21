import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/bus_stops/data/models/bus_stop_model.dart';
import 'package:hinam/features/eta/presentation/providers/eta_provider.dart';

class StopDetailSheet extends ConsumerWidget {
  final BusStopModel stop;
  final ScrollController scrollController;

  const StopDetailSheet({
    super.key,
    required this.stop,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final buses = ref.watch(stopEtaProvider(stop.id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
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

          // Stop header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.signpost_rounded, color: Color(0xFFEA580C), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stop.name, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    Text(
                      'Bus Stop',
                      style: text.bodySmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: buses.isNotEmpty
                      ? Colors.green.withValues(alpha: 0.1)
                      : scheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${buses.length} approaching',
                  style: text.labelSmall?.copyWith(
                    color: buses.isNotEmpty ? Colors.green[700] : scheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          Text(
            buses.isEmpty ? 'NO BUSES APPROACHING' : 'APPROACHING BUSES',
            style: text.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          if (buses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.directions_bus_outlined, size: 20, color: scheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(width: 10),
                  Text(
                    'No active buses nearby',
                    style: text.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: buses.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final result = buses[i];
                  final isPublic = result.busType == 'public';
                  final routeOrSchool = result.routeName ?? result.schoolName;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isPublic ? Icons.directions_bus_rounded : Icons.school_rounded,
                            color: scheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.busNumber,
                                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (routeOrSchool != null)
                                Text(
                                  routeOrSchool,
                                  style: text.bodySmall?.copyWith(
                                    color: scheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              result.formattedEta,
                              style: text.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.primary,
                              ),
                            ),
                            Text(
                              result.formattedDistance,
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
