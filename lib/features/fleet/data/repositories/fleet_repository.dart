import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/shared/providers/firebase_providers.dart';

import '../datasources/fleet_remote_datasource.dart';
import '../models/assignment_model.dart';
import '../models/bus_model.dart';

final fleetRepositoryProvider = Provider<FleetRepository>((ref) {
  return FleetRepository(FleetRemoteDatasource(ref.read(firestoreProvider)));
});

class FleetRepository {
  final FleetRemoteDatasource datasource;

  FleetRepository(this.datasource);

  // ── Buses ────────────────────────────────────────────────

  Stream<List<BusModel>> watchBuses() => datasource.watchBuses();

  Future<void> addBus({
    required String busNumber,
    required String busType,
    String? routeName,
    String? schoolName,
  }) {
    final bus = BusModel(
      id: '',
      busNumber: busNumber,
      busType: busType,
      routeName: routeName,
      schoolName: schoolName,
      createdAt: Timestamp.now(),
    );
    return datasource.addBus(bus);
  }

  Future<void> deleteBus(String id) => datasource.deleteBus(id);

  // ── Assignments ──────────────────────────────────────────

  Stream<List<AssignmentModel>> watchAssignmentsForDate(String date) =>
      datasource.watchAssignmentsForDate(date);

  Stream<AssignmentModel?> watchActiveAssignment({
    required String driverId,
    required String date,
  }) =>
      datasource.watchActiveAssignment(driverId: driverId, date: date);

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
  }) {
    final assignment = AssignmentModel(
      id: '',
      busId: busId,
      driverId: driverId,
      driverName: driverName,
      busNumber: busNumber,
      busType: busType,
      routeName: routeName,
      schoolName: schoolName,
      shift: shift,
      date: date,
      status: 'active',
      createdAt: Timestamp.now(),
    );
    return datasource.addAssignment(assignment);
  }

  Future<void> cancelAssignment(String id) =>
      datasource.updateAssignmentStatus(id, 'cancelled');

  Future<void> completeAssignment(String id) =>
      datasource.updateAssignmentStatus(id, 'completed');
}
