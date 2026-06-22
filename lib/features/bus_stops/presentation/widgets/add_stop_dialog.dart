import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/bus_stops/presentation/providers/bus_stop_controller.dart';
import 'package:hinam/features/tracking/presentation/providers/tracking_provider.dart';

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

    await ref
        .read(busStopControllerProvider.notifier)
        .addStop(name: name, latitude: _latitude!, longitude: _longitude!);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasLocation = _latitude != null && _longitude != null;
    final canSave = _nameController.text.trim().isNotEmpty && hasLocation;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                    color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_location_alt_rounded,
                    color: Color(0xFFEA580C),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Add Bus Stop',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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

            const SizedBox(height: 16),

            // Location button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: hasLocation
                    ? Colors.green.withValues(alpha: 0.06)
                    : scheme.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasLocation
                      ? Colors.green.withValues(alpha: 0.3)
                      : scheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: ListTile(
                onTap: _isFetchingLocation ? null : _useCurrentLocation,
                leading: _isFetchingLocation
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    : Icon(
                        hasLocation
                            ? Icons.check_circle_rounded
                            : Icons.my_location_rounded,
                        color: hasLocation ? Colors.green : scheme.primary,
                        size: 20,
                      ),
                title: Text(
                  hasLocation ? 'Location captured' : 'Use current location',
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: hasLocation ? Colors.green[700] : scheme.primary,
                  ),
                ),
                subtitle: hasLocation
                    ? Text(
                        '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minLeadingWidth: 24,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canSave ? _save : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46),
                    ),
                    child: const Text('Save Stop'),
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
