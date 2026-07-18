import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/bus_stops/presentation/providers/bus_stop_controller.dart';
import 'package:hinam/features/tracking/presentation/providers/tracking_provider.dart';
import 'package:hinam/shared/widgets/loading_button.dart';

class AddStopDialog extends ConsumerStatefulWidget {
  const AddStopDialog({super.key});

  @override
  ConsumerState<AddStopDialog> createState() => _AddStopDialogState();
}

class _AddStopDialogState extends ConsumerState<AddStopDialog> {
  final _nameController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _isFetchingLocation = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _latitude == null || _longitude == null) return;

    setState(() => _isSaving = true);

    try {
      await ref
          .read(busStopControllerProvider.notifier)
          .addStop(name: name, latitude: _latitude!, longitude: _longitude!);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save stop: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _latitude != null && _longitude != null;
    final canSave =
        _nameController.text.trim().isNotEmpty && hasLocation && !_isSaving;

    return Dialog(
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
                    color: AppColors.stopOrangeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_location_alt_rounded,
                    color: AppColors.stopOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Bus Stop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Stop Name',
                hintText: 'e.g. Ratna Park, Kalanki',
                prefixIcon: Icon(Icons.signpost_rounded, size: 18),
              ),
            ),

            const SizedBox(height: 14),

            GestureDetector(
              onTap: _isFetchingLocation ? null : _useCurrentLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: hasLocation
                      ? AppColors.successBg
                      : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasLocation
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    if (_isFetchingLocation)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      Icon(
                        hasLocation
                            ? Icons.check_circle_rounded
                            : Icons.my_location_rounded,
                        size: 18,
                        color: hasLocation
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasLocation
                                ? 'Location captured'
                                : 'Use current location',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: hasLocation
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                          if (hasLocation) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
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
                    text: 'Save Stop',
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
