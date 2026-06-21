import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/bus_stops/data/models/bus_stop_model.dart';
import 'package:hinam/features/bus_stops/presentation/providers/bus_stop_controller.dart';

class BusStopTile extends ConsumerWidget {
  final BusStopModel stop;

  const BusStopTile({super.key, required this.stop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.signpost_rounded, color: Color(0xFFEA580C), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.name, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${stop.latitude.toStringAsFixed(5)}, ${stop.longitude.toStringAsFixed(5)}',
                  style: text.bodySmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.45)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, ref),
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: scheme.error.withValues(alpha: 0.7)),
            style: IconButton.styleFrom(
              backgroundColor: scheme.error.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Stop?'),
        content: Text('Remove "${stop.name}" from bus stops?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(busStopControllerProvider.notifier).deleteStop(stop.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
