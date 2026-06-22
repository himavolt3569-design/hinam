import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/passenger/presentation/providers/bus_locations_provider.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}

final filteredBusesProvider = Provider<AsyncValue<List<BusLocationModel>>>((
  ref,
) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final busesAsync = ref.watch(busLocationsProvider);

  if (query.isEmpty) return busesAsync;

  return busesAsync.whenData((buses) {
    return buses.where((bus) {
      return bus.busNumber.toLowerCase().contains(query) ||
          (bus.routeName?.toLowerCase().contains(query) ?? false) ||
          (bus.schoolName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});
