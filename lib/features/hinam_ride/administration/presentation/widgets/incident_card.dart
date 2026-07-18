import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/administration/data/models/ride_incident_model.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_incident_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_participant_name_provider.dart';

/// Deliberately styled as an alarm, not a routine review card — solid red
/// header, no gentle pastel badges — per the product requirement that SOS
/// incidents must be visually unmistakable from ordinary admin queue items.
class IncidentCard extends ConsumerWidget {
  final RideIncidentModel incident;

  const IncidentCard({super.key, required this.incident});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(
      rideParticipantNameProvider(incident.triggeredBy),
    );
    final controller = ref.read(incidentReviewControllerProvider.notifier);
    final isAcknowledged = incident.status == RideIncidentStatus.acknowledged;
    final mapsUri = Uri.parse(
      'https://maps.google.com/?q=${incident.location.latitude},${incident.location.longitude}',
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'SOS EMERGENCY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  isAcknowledged ? 'ACKNOWLEDGED' : 'UNACKNOWLEDGED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Triggered by ${nameAsync.asData?.value ?? 'Loading…'}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  incident.createdAt.toDate().toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => launchUrl(mapsUri),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        incident.location.address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (!isAcknowledged)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => controller.acknowledge(incident.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Acknowledge'),
                        ),
                      ),
                    if (!isAcknowledged) const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => controller.resolve(incident.id),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Resolve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
