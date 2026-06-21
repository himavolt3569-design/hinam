import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/features/admin/presentation/providers/admin_providers.dart';
import 'package:hinam/features/admin/presentation/widgets/live_bus_tile.dart';
import 'package:hinam/features/admin/presentation/widgets/quick_action_tile.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingDriversProvider);
    final activeBusesAsync = ref.watch(adminActiveBusesProvider);
    final allDriversAsync = ref.watch(allDriversProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final pendingCount = pendingAsync.asData?.value.length ?? 0;
    final activeCount = activeBusesAsync.asData?.value.length ?? 0;
    final totalDrivers = allDriversAsync.asData?.value.length ?? 0;

    return Scaffold(
      body: Column(
        children: [
          // ── Gradient header ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.primary.withValues(alpha: 0.85)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Panel',
                                style: text.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Hinam Control Center',
                                style: text.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                          icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          tooltip: 'Logout',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _WhiteStatCard(
                            icon: Icons.people_rounded,
                            label: 'Drivers',
                            value: '$totalDrivers',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _WhiteStatCard(
                            icon: Icons.directions_bus_rounded,
                            label: 'Active',
                            value: '$activeCount',
                            highlight: activeCount > 0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _WhiteStatCard(
                            icon: Icons.pending_actions_rounded,
                            label: 'Pending',
                            value: '$pendingCount',
                            highlight: pendingCount > 0,
                            highlightColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  QuickActionTile(
                    icon: Icons.how_to_reg_rounded,
                    title: 'Pending Approvals',
                    subtitle: pendingCount > 0 ? '$pendingCount drivers waiting for review' : 'All drivers approved',
                    badge: pendingCount,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.pendingDrivers),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Live Buses', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      if (activeCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$activeCount online',
                            style: text.labelSmall?.copyWith(color: Colors.green[700], fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  activeBusesAsync.when(
                    data: (buses) {
                      if (buses.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.directions_bus_outlined, size: 20, color: scheme.onSurface.withValues(alpha: 0.3)),
                              const SizedBox(width: 12),
                              Text(
                                'No buses currently active',
                                style: text.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.4)),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: buses.map((bus) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LiveBusTile(bus: bus),
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text(e.toString())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final Color? highlightColor;

  const _WhiteStatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = highlight ? (highlightColor ?? Colors.green) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: highlight ? effectiveColor : Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: highlight ? effectiveColor : Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
