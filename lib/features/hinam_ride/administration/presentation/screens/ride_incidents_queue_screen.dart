import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_incident_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/widgets/incident_card.dart';
import 'package:hinam/shared/widgets/empty_state_view.dart';

class RideIncidentsQueueScreen extends ConsumerWidget {
  const RideIncidentsQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openAsync = ref.watch(openIncidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Incidents'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: openAsync.when(
        data: (incidents) {
          if (incidents.isEmpty) {
            return EmptyStateView(
              icon: Icons.shield_rounded,
              iconColor: AppColors.success,
              iconBackgroundColor: AppColors.success.withValues(alpha: 0.08),
              title: 'No active incidents',
              subtitle:
                  'You will be notified immediately if an SOS is triggered.',
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
