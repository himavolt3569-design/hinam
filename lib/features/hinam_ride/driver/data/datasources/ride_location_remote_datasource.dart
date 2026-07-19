import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/driver/data/models/ride_location_model.dart';

class RideLocationRemoteDatasource {
  final FirebaseFirestore firestore;

  RideLocationRemoteDatasource(this.firestore);

  Future<void> updateLocation(RideLocationModel location) async {
    await firestore
        .collection('ride_locations')
        .doc(location.driverId)
        .set(location.toMap());
  }

  Future<void> clearLocation(String driverId) async {
    await firestore.collection('ride_locations').doc(driverId).set({
      'isOnline': false,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
