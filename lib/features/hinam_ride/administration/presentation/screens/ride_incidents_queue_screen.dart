import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_incident_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/widgets/incident_card.dart';

class RideIncidentsQueueScreen extends ConsumerWidget {
  const RideIncidentsQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openAsync = ref.watch(openIncidentsProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Incidents'),
        centerTitle: true,
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: openAsync.when(
        data: (incidents) {
          if (incidents.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_rounded,
                      size: 38,
                      color: AppColors.success.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active incidents',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You will be notified immediately if an SOS is triggered.',
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: incidents.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) => IncidentCard(incident: incidents[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
