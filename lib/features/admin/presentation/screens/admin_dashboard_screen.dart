import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/admin/presentation/providers/admin_providers.dart';
import 'package:hinam/features/admin/presentation/widgets/live_bus_tile.dart';
import 'package:hinam/features/admin/presentation/widgets/quick_action_tile.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_admin_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_incident_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_report_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingDriversProvider);
    final activeBusesAsync = ref.watch(adminActiveBusesProvider);
    final allDriversAsync = ref.watch(allDriversProvider);
    final text = Theme.of(context).textTheme;

    final pendingCount = pendingAsync.asData?.value.length ?? 0;
    final activeCount = activeBusesAsync.asData?.value.length ?? 0;
    final totalDrivers = allDriversAsync.asData?.value.length ?? 0;

    final rideVerificationCount =
        ref.watch(pendingRideVerificationsProvider).asData?.value.length ?? 0;
    final rideReportCount =
        ref.watch(openReportsProvider).asData?.value.length ?? 0;
    final rideIncidentCount =
        ref.watch(openIncidentsProvider).asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded, size: 20),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_rounded,
                    label: 'Drivers',
                    value: '$totalDrivers',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.directions_bus_rounded,
                    label: 'Active',
                    value: '$activeCount',
                    badge: activeCount > 0 ? AppColors.success : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending',
                    value: '$pendingCount',
                    badge: pendingCount > 0 ? AppColors.warning : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Quick Actions',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            QuickActionTile(
              icon: Icons.how_to_reg_rounded,
              title: 'Pending Approvals',
              subtitle: pendingCount > 0
                  ? '$pendingCount drivers waiting for review'
                  : 'All drivers approved',
              badge: pendingCount,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.pendingDrivers),
            ),

            const SizedBox(height: 8),

            QuickActionTile(
              icon: Icons.directions_bus_rounded,
              title: 'Fleet Management',
              subtitle: 'Manage buses and driver assignments',
              badge: 0,
              onTap: () => Navigator.pushNamed(context, AppRoutes.manageBuses),
            ),

            const SizedBox(height: 8),

            _RideAdminSummaryTile(
              pendingCount: rideVerificationCount + rideReportCount,
              incidentCount: rideIncidentCount,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.rideAdminHome),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Buses',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (activeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$activeCount online',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            activeBusesAsync.when(
              data: (buses) {
                if (buses.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'No buses currently active',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: buses
                      .map(
                        (bus) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LiveBusTile(bus: bus),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? badge;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = badge ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badge != null
              ? badge!.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: effectiveColor, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: effectiveColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Links to the Ride admin hub (Phase 19). Unlike [QuickActionTile]'s single
/// badge, an open SOS incident must stay visually unmistakable from routine
/// verification/report backlog, so the two counts render as separately
/// colored badges rather than being summed into one number.
class _RideAdminSummaryTile extends StatelessWidget {
  final int pendingCount;
  final int incidentCount;
  final VoidCallback onTap;

  const _RideAdminSummaryTile({
    required this.pendingCount,
    required this.incidentCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasIncident = incidentCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasIncident ? AppColors.error : AppColors.border,
            width: hasIncident ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hinam Ride Administration',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasIncident
                        ? '$incidentCount active SOS incident${incidentCount == 1 ? '' : 's'}'
                        : 'Verification, reports & incidents',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasIncident
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontWeight: hasIncident
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (hasIncident) ...[
              Container(
                key: const Key('rideIncidentBadge'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$incidentCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (pendingCount > 0) ...[
              Container(
                key: const Key('ridePendingBadge'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pendingCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
