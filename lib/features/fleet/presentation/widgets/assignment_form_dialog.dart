import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/admin/presentation/providers/admin_providers.dart';
import 'package:hinam/shared/models/driver_model.dart';
import 'package:hinam/features/fleet/data/models/bus_model.dart';
import 'package:hinam/features/fleet/presentation/providers/fleet_providers.dart';

class AssignmentFormDialog extends ConsumerStatefulWidget {
  final String? initialDate;

  const AssignmentFormDialog({super.key, this.initialDate});

  @override
  ConsumerState<AssignmentFormDialog> createState() => _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends ConsumerState<AssignmentFormDialog> {
  DriverModel? _selectedDriver;
  BusModel? _selectedBus;
  String _shift = 'full';
  bool _isSaving = false;
  late String _date;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now().toIso8601String().substring(0, 10);
  }

  Future<void> _save() async {
    if (_selectedDriver == null || _selectedBus == null) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(fleetControllerProvider.notifier).createAssignment(
            busId: _selectedBus!.id,
            driverId: _selectedDriver!.uid,
            driverName: _selectedDriver!.fullName,
            busNumber: _selectedBus!.busNumber,
            busType: _selectedBus!.busType,
            routeName: _selectedBus!.routeName,
            schoolName: _selectedBus!.schoolName,
            shift: _shift,
            date: _date,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Widget _dropdownField<T>({
    required IconData icon,
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              hint: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textTertiary)),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(10),
              items: items,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(allDriversProvider);
    final busesAsync = ref.watch(allBusesProvider);
    final canSave = _selectedDriver != null && _selectedBus != null && !_isSaving;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New Assignment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date picker row
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(_date) ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => _date = picked.toIso8601String().substring(0, 10));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(_date, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      const Spacer(),
                      const Icon(Icons.edit_calendar_rounded, size: 14, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Driver selector
              driversAsync.when(
                data: (drivers) {
                  final approved = drivers.where((d) => d.isApproved).toList();
                  return _dropdownField<DriverModel>(
                    icon: Icons.person_outlined,
                    label: 'Select Driver',
                    value: _selectedDriver,
                    items: approved
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d.fullName, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedDriver = v),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Failed to load drivers'),
              ),
              const SizedBox(height: 12),

              // Bus selector
              busesAsync.when(
                data: (buses) => _dropdownField<BusModel>(
                  icon: Icons.directions_bus_outlined,
                  label: 'Select Bus',
                  value: _selectedBus,
                  items: buses
                      .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(
                              '${b.busNumber} · ${b.routeOrSchool}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBus = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Failed to load buses'),
              ),
              const SizedBox(height: 12),

              // Shift selector
              _dropdownField<String>(
                icon: Icons.schedule_rounded,
                label: 'Shift',
                value: _shift,
                items: const [
                  DropdownMenuItem(value: 'morning', child: Text('Morning')),
                  DropdownMenuItem(value: 'afternoon', child: Text('Afternoon')),
                  DropdownMenuItem(value: 'full', child: Text('Full Day')),
                ],
                onChanged: (v) => setState(() => _shift = v ?? 'full'),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: canSave ? _save : null,
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Assign'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
