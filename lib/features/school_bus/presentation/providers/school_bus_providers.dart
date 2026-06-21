import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/passenger/presentation/providers/bus_locations_provider.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

/// All active school buses.
final schoolBusesProvider = Provider<AsyncValue<List<BusLocationModel>>>((ref) {
  return ref.watch(busLocationsProvider).whenData(
        (buses) => buses.where((b) => b.busType == 'school').toList(),
      );
});

/// Unique school names from active school buses.
final activeSchoolNamesProvider = Provider<List<String>>((ref) {
  final buses = ref.watch(schoolBusesProvider).asData?.value ?? [];
  final names = buses.map((b) => b.schoolName ?? '').where((n) => n.isNotEmpty).toSet().toList()..sort();
  return names;
});

/// School buses filtered by selected school name (empty string = all).
final filteredSchoolBusesProvider = Provider.family<List<BusLocationModel>, String>((ref, schoolName) {
  final buses = ref.watch(schoolBusesProvider).asData?.value ?? [];
  if (schoolName.isEmpty) return buses;
  return buses.where((b) => b.schoolName == schoolName).toList();
});
