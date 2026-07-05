import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/fleet/data/models/assignment_model.dart';
import 'package:hinam/features/fleet/data/models/bus_model.dart';
import 'package:hinam/features/fleet/data/repositories/fleet_repository.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final allBusesProvider = StreamProvider<List<BusModel>>((ref) {
  return ref.watch(fleetRepositoryProvider).watchBuses();
});

final todayAssignmentsProvider = StreamProvider<List<AssignmentModel>>((ref) {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return ref.watch(fleetRepositoryProvider).watchAssignmentsForDate(today);
});

final activeAssignmentProvider = StreamProvider<AssignmentModel?>((ref) {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (uid == null) return Stream.value(null);
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return ref.watch(fleetRepositoryProvider).watchActiveAssignment(
        driverId: uid,
        date: today,
      );
});

final fleetControllerProvider =
    AsyncNotifierProvider<FleetController, void>(FleetController.new);

class FleetController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addBus({
    required String busNumber,
    required String busType,
    String? routeName,
    String? schoolName,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(fleetRepositoryProvider).addBus(
            busNumber: busNumber,
            busType: busType,
            routeName: routeName,
            schoolName: schoolName,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteBus(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(fleetRepositoryProvider).deleteBus(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> createAssignment({
    required String busId,
    required String driverId,
    required String driverName,
    required String busNumber,
    required String busType,
    String? routeName,
    String? schoolName,
    required String shift,
    required String date,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(fleetRepositoryProvider).createAssignment(
            busId: busId,
            driverId: driverId,
            driverName: driverName,
            busNumber: busNumber,
            busType: busType,
            routeName: routeName,
            schoolName: schoolName,
            shift: shift,
            date: date,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> cancelAssignment(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(fleetRepositoryProvider).cancelAssignment(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
