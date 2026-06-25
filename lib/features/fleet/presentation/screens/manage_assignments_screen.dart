import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/fleet/data/models/assignment_model.dart';
import 'package:hinam/features/fleet/data/repositories/fleet_repository.dart';
import 'package:hinam/features/fleet/presentation/widgets/assignment_form_dialog.dart';

class ManageAssignmentsScreen extends ConsumerStatefulWidget {
  const ManageAssignmentsScreen({super.key});

  @override
  ConsumerState<ManageAssignmentsScreen> createState() => _ManageAssignmentsScreenState();
}

class _ManageAssignmentsScreenState extends ConsumerState<ManageAssignmentsScreen> {
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().toIso8601String().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(
      _assignmentsForDateProvider(_selectedDate),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Assignments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AssignmentFormDialog(initialDate: _selectedDate),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Assign'),
      ),
      body: Column(
        children: [
          // Date selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(_selectedDate) ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked.toIso8601String().substring(0, 10));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate == DateTime.now().toIso8601String().substring(0, 10)
                          ? 'Today — $_selectedDate'
                          : _selectedDate,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    const Icon(Icons.unfold_more_rounded, size: 16, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: assignmentsAsync.when(
              data: (assignments) {
                if (assignments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(color: AppColors.inputFill, shape: BoxShape.circle),
                            child: const Icon(Icons.assignment_outlined, size: 32, color: AppColors.textTertiary),
                          ),
                          const SizedBox(height: 16),
                          const Text('No assignments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          const Text('Tap "Assign" to create a new assignment.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: assignments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _AssignmentCard(assignment: assignments[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

// Local provider scoped to the selected date
final _assignmentsForDateProvider =
    StreamProvider.family<List<AssignmentModel>, String>((ref, date) {
  return ref.watch(fleetRepositoryProvider).watchAssignmentsForDate(date);
});

class _AssignmentCard extends ConsumerWidget {
  final AssignmentModel assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPublic = assignment.busType == 'public';
    final statusColor = switch (assignment.status) {
      'active' => AppColors.success,
      'completed' => AppColors.primary,
      _ => AppColors.textTertiary,
    };
    final statusBg = switch (assignment.status) {
      'active' => AppColors.successBg,
      'completed' => AppColors.primaryBg,
      _ => AppColors.inputFill,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPublic ? AppColors.primaryBg : AppColors.schoolGreenBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPublic ? Icons.directions_bus_rounded : Icons.school_rounded,
                  size: 18,
                  color: isPublic ? AppColors.primary : AppColors.schoolGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(assignment.busNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (assignment.routeOrSchool.isNotEmpty)
                      Text(assignment.routeOrSchool, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  assignment.status[0].toUpperCase() + assignment.status.substring(1),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_rounded, size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(assignment.driverName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 14),
              const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(assignment.shiftLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          if (assignment.isActive) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(context, ref, 'completed'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Mark Complete', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(context, ref, 'cancelled'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    try {
      if (status == 'completed') {
        await ref.read(fleetRepositoryProvider).completeAssignment(assignment.id);
      } else {
        await ref.read(fleetRepositoryProvider).cancelAssignment(assignment.id);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }
}
