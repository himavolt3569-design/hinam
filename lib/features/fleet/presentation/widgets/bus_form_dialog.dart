import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/fleet/presentation/providers/fleet_providers.dart';
import 'package:hinam/shared/widgets/loading_button.dart';

class BusFormDialog extends ConsumerStatefulWidget {
  const BusFormDialog({super.key});

  @override
  ConsumerState<BusFormDialog> createState() => _BusFormDialogState();
}

class _BusFormDialogState extends ConsumerState<BusFormDialog> {
  final _busNumberController = TextEditingController();
  final _routeController = TextEditingController();
  final _schoolController = TextEditingController();
  String _busType = 'public';
  bool _isSaving = false;

  @override
  void dispose() {
    _busNumberController.dispose();
    _routeController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final busNumber = _busNumberController.text.trim();
    if (busNumber.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(fleetControllerProvider.notifier).addBus(
            busNumber: busNumber,
            busType: _busType,
            routeName: _busType == 'public' ? _routeController.text.trim() : null,
            schoolName: _busType == 'school' ? _schoolController.text.trim() : null,
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

  @override
  Widget build(BuildContext context) {
    final canSave = _busNumberController.text.trim().isNotEmpty && !_isSaving;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
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
                  child: const Icon(Icons.directions_bus_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Bus',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _busNumberController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Bus Number',
                hintText: 'Ba 3 Kha 1234',
                prefixIcon: Icon(Icons.numbers_rounded, size: 18),
              ),
            ),
            const SizedBox(height: 14),

            // Bus type toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _busType = 'public'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _busType == 'public' ? AppColors.primary : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Public',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _busType == 'public' ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _busType = 'school'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _busType == 'school' ? AppColors.schoolGreen : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'School',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _busType == 'school' ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (_busType == 'public')
              TextField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  hintText: 'Kalanki → Ratnapark',
                  prefixIcon: Icon(Icons.route_outlined, size: 18),
                ),
              ),

            if (_busType == 'school')
              TextField(
                controller: _schoolController,
                decoration: const InputDecoration(
                  labelText: 'School Name',
                  hintText: 'ABC Secondary School',
                  prefixIcon: Icon(Icons.school_outlined, size: 18),
                ),
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
                  child: LoadingButton(
                    text: 'Add Bus',
                    isLoading: _isSaving,
                    onPressed: canSave ? _save : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
