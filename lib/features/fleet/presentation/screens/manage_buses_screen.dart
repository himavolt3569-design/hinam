import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/fleet/data/models/bus_model.dart';
import 'package:hinam/features/fleet/presentation/providers/fleet_providers.dart';
import 'package:hinam/features/fleet/presentation/widgets/bus_form_dialog.dart';
import 'package:hinam/shared/widgets/empty_state_view.dart';

class ManageBusesScreen extends ConsumerWidget {
  const ManageBusesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busesAsync = ref.watch(allBusesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fleet Management'),
        actions: [
          TextButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.manageAssignments),
            icon: const Icon(Icons.assignment_rounded, size: 18),
            label: const Text('Assignments'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            showDialog(context: context, builder: (_) => const BusFormDialog()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Bus'),
      ),
      body: busesAsync.when(
        data: (buses) {
          if (buses.isEmpty) {
            return const EmptyStateView(
              icon: Icons.directions_bus_outlined,
              title: 'No buses in fleet',
              subtitle: 'Tap "Add Bus" to register a bus.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: buses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _BusTile(bus: buses[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _BusTile extends ConsumerWidget {
  final BusModel bus;

  const _BusTile({required this.bus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bus.isPublic
                  ? AppColors.primaryBg
                  : AppColors.schoolGreenBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              bus.isPublic
                  ? Icons.directions_bus_rounded
                  : Icons.school_rounded,
              size: 20,
              color: bus.isPublic ? AppColors.primary : AppColors.schoolGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.busNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  bus.routeOrSchool.isEmpty
                      ? (bus.isPublic ? 'Public Bus' : 'School Bus')
                      : bus.routeOrSchool,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bus.isPublic
                  ? AppColors.primaryBg
                  : AppColors.schoolGreenBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              bus.isPublic ? 'Public' : 'School',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: bus.isPublic ? AppColors.primary : AppColors.schoolGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.textTertiary,
            ),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Bus'),
        content: Text('Remove ${bus.busNumber} from the fleet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(fleetControllerProvider.notifier).deleteBus(bus.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    }
  }
}
