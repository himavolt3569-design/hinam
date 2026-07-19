import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/shared/models/bus_location_model.dart';

class TrackingRemoteDatasource {
  final FirebaseFirestore firestore;

  TrackingRemoteDatasource(this.firestore);

  Future<void> updateBusLocation(BusLocationModel location) async {
    await firestore
        .collection('bus_locations')
        .doc(location.driverId)
        .set(location.toMap());
  }

  Future<void> clearBusLocation(String driverId) async {
    await firestore.collection('bus_locations').doc(driverId).set({
      'isTracking': false,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> updateStudentCount(String driverId, int count) async {
    await firestore.collection('bus_locations').doc(driverId).set({
      'studentCount': count,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
