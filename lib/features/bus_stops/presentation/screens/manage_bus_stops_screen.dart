import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/bus_stops/presentation/providers/bus_stops_provider.dart';
import 'package:hinam/features/bus_stops/presentation/widgets/add_stop_dialog.dart';
import 'package:hinam/features/bus_stops/presentation/widgets/bus_stop_tile.dart';

class ManageBusStopsScreen extends ConsumerWidget {
  const ManageBusStopsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopsAsync = ref.watch(busStopsProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bus Stops')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            showDialog(context: context, builder: (_) => const AddStopDialog()),
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Stop'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
      ),
      body: stopsAsync.when(
        data: (stops) {
          if (stops.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.signpost_outlined,
                      size: 36,
                      color: const Color(0xFFEA580C).withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No stops yet',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Add Stop" to add your first bus stop.',
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: stops.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => BusStopTile(stop: stops[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
