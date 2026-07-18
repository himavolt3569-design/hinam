import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_incident_providers.dart';
import 'package:hinam/features/hinam_ride/passenger/data/models/ride_passenger_model.dart'
    show EmergencyContact;
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart'
    show RideLocation;

/// Builds the native SMS-compose intent for the given contacts and message.
/// A pure function so the URI construction is directly unit-testable without
/// a device or an SMS app — only the actual `launchUrl` call needs one.
Uri buildEmergencySmsUri(List<EmergencyContact> contacts, String message) {
  return Uri(
    scheme: 'sms',
    path: contacts.map((c) => c.phone).join(','),
    queryParameters: {'body': message},
  );
}

String buildSosMessage(RideLocation location) {
  return 'SOS: I need help during my Hinam Ride and may not be able to talk. '
      'My last known location: '
      'https://maps.google.com/?q=${location.latitude},${location.longitude}';
}

class SosButton extends ConsumerWidget {
  final String rideId;
  final List<EmergencyContact> emergencyContacts;

  const SosButton({
    super.key,
    required this.rideId,
    required this.emergencyContacts,
  });

  Future<void> _confirmAndTrigger(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Trigger SOS?'),
        content: const Text(
          'This immediately alerts Hinam admins and texts your emergency '
          'contacts with your current location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Trigger SOS'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final location = await ref
        .read(incidentTriggerControllerProvider.notifier)
        .triggerSos(rideId);

    // Attempted unconditionally — this is the channel that must still work
    // when the incident write above can't reach the server (offline).
    if (emergencyContacts.isNotEmpty) {
      final uri = buildEmergencySmsUri(
        emergencyContacts,
        buildSosMessage(location),
      );
      try {
        await launchUrl(uri);
      } catch (_) {
        // No SMS-capable app available on this device — the admin alert
        // above is independent and already attempted.
      }
    }

    if (!context.mounted) return;

    final error = ref.read(incidentTriggerControllerProvider).error;
    final message = error != null
        ? error.toString()
        : emergencyContacts.isNotEmpty
        ? 'SOS sent. Admins alerted and emergency contacts messaged.'
        : 'SOS sent. Admins have been alerted.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTriggering = ref.watch(incidentTriggerControllerProvider).isLoading;

    return FilledButton.icon(
      onPressed: isTriggering ? null : () => _confirmAndTrigger(context, ref),
      style: FilledButton.styleFrom(backgroundColor: AppColors.error),
      icon: const Icon(Icons.sos_rounded, size: 20),
      label: Text(isTriggering ? 'Sending SOS…' : 'SOS'),
    );
  }
}
