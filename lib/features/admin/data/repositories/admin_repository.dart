import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/shared/models/driver_model.dart';
import 'package:hinam/shared/models/bus_location_model.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(firestoreProvider));
});

class AdminRepository {
  final FirebaseFirestore firestore;

  AdminRepository(this.firestore);

  Future<bool> isAdmin(String uid) async {
    final doc = await firestore.collection('admins').doc(uid).get();
    return doc.exists;
  }

  Stream<List<DriverModel>> watchPendingDrivers() {
    return firestore
        .collection('drivers')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => DriverModel.fromMap(d.data())).toList());
  }

  Stream<List<DriverModel>> watchAllDrivers() {
    return firestore
        .collection('drivers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => DriverModel.fromMap(d.data())).toList());
  }

  Stream<List<BusLocationModel>> watchActiveBuses() {
    return firestore
        .collection('bus_locations')
        .where('isTracking', isEqualTo: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => BusLocationModel.fromMap(d.data())).toList(),
        );
  }

  Future<void> approveDriver(String uid) async {
    await firestore.collection('drivers').doc(uid).update({'isApproved': true});
  }

  Future<void> rejectDriver(String uid) async {
    await firestore.collection('drivers').doc(uid).delete();
  }
}
