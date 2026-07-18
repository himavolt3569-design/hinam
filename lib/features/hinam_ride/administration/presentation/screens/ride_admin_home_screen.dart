import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/admin/presentation/widgets/quick_action_tile.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_admin_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_incident_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_report_providers.dart';

/// Single entry point linking the three Ride admin queues (Phases 6, 17, 18)
/// without merging their independent providers/repositories together.
class RideAdminHomeScreen extends ConsumerWidget {
  const RideAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount =
        ref.watch(pendingRideVerificationsProvider).asData?.value.length ?? 0;
    final reportCount =
        ref.watch(openReportsProvider).asData?.value.length ?? 0;
    final incidentCount =
        ref.watch(openIncidentsProvider).asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ride Administration'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          QuickActionTile(
            icon: Icons.verified_user_rounded,
            title: 'Verification Queue',
            subtitle: pendingCount > 0
                ? '$pendingCount pending driver/passenger reviews'
                : 'No pending verifications',
            badge: pendingCount,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.rideVerificationQueue),
          ),
          const SizedBox(height: 12),
          QuickActionTile(
            icon: Icons.flag_rounded,
            title: 'Reports Queue',
            subtitle: reportCount > 0
                ? '$reportCount reports awaiting review'
                : 'No open reports',
            badge: reportCount,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.rideReportsQueue),
          ),
          const SizedBox(height: 12),
          QuickActionTile(
            icon: Icons.emergency_rounded,
            title: 'SOS Incidents',
            subtitle: incidentCount > 0
                ? '$incidentCount active emergency incidents'
                : 'No active incidents',
            badge: incidentCount,
            badgeColor: AppColors.error,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.rideIncidentsQueue),
          ),
        ],
      ),
    );
  }
}
