import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/assignment_model.dart';
import '../models/bus_model.dart';

class FleetRemoteDatasource {
  final FirebaseFirestore firestore;

  FleetRemoteDatasource(this.firestore);

  // ── Buses ────────────────────────────────────────────────

  Stream<List<BusModel>> watchBuses() {
    return firestore
        .collection('buses')
        .orderBy('busNumber')
        .snapshots()
        .map((s) => s.docs.map((d) => BusModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> addBus(BusModel bus) async {
    await firestore.collection('buses').add(bus.toMap());
  }

  Future<void> deleteBus(String id) async {
    await firestore.collection('buses').doc(id).delete();
  }

  // ── Assignments ──────────────────────────────────────────

  Stream<List<AssignmentModel>> watchAssignmentsForDate(String date) {
    return firestore
        .collection('assignments')
        .where('date', isEqualTo: date)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AssignmentModel.fromMap(d.id, d.data())).toList());
  }

  Stream<AssignmentModel?> watchActiveAssignment({
    required String driverId,
    required String date,
  }) {
    return firestore
        .collection('assignments')
        .where('driverId', isEqualTo: driverId)
        .where('date', isEqualTo: date)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : AssignmentModel.fromMap(s.docs.first.id, s.docs.first.data()));
  }

  Future<void> addAssignment(AssignmentModel assignment) async {
    await firestore.collection('assignments').add(assignment.toMap());
  }

  Future<void> updateAssignmentStatus(String id, String status) async {
    await firestore.collection('assignments').doc(id).update({'status': status});
  }
}
