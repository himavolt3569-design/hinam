import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/passenger/presentation/providers/bus_locations_provider.dart';
import 'package:hinam/features/passenger/presentation/providers/bus_search_provider.dart';
import 'package:hinam/features/passenger/presentation/widgets/bus_list_card.dart';
import 'package:hinam/shared/models/bus_location_model.dart';
import 'package:hinam/shared/widgets/empty_state_view.dart';

class PublicBusListScreen extends ConsumerStatefulWidget {
  const PublicBusListScreen({super.key});

  @override
  ConsumerState<PublicBusListScreen> createState() =>
      _PublicBusListScreenState();
}

class _PublicBusListScreenState extends ConsumerState<PublicBusListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BusLocationModel> _filter(List<BusLocationModel> buses, String query) {
    if (query.isEmpty) return buses;
    final q = query.toLowerCase();
    return buses.where((b) {
      return b.busNumber.toLowerCase().contains(q) ||
          (b.routeName?.toLowerCase().contains(q) ?? false) ||
          b.driverName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final publicBusesAsync = ref.watch(publicBusesProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Nearby Buses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).update(v),
              decoration: InputDecoration(
                hintText: 'Search bus number or route…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: publicBusesAsync.when(
              data: (buses) {
                final filtered = _filter(buses, query);

                if (buses.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.directions_bus_outlined,
                    title: 'No active buses',
                    subtitle: 'No buses are currently tracking their location.',
                  );
                }

                if (filtered.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No results',
                    subtitle: 'Try a different bus number or route name.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => BusListCard(
                    bus: filtered[i],
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.singleBusMap,
                      arguments: filtered[i].driverId,
                    ),
                  ),
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
