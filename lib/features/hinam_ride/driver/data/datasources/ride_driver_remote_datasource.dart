import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/driver/data/models/ride_driver_model.dart';

class RideDriverRemoteDatasource {
  final FirebaseFirestore firestore;

  RideDriverRemoteDatasource(this.firestore);

  Future<bool> driverExists(String uid) async {
    final doc = await firestore.collection('ride_drivers').doc(uid).get();

    return doc.exists;
  }

  Future<void> createDriver(RideDriverModel driver) async {
    await firestore
        .collection('ride_drivers')
        .doc(driver.uid)
        .set(driver.toMap());
  }

  Future<RideDriverModel?> getDriver(String uid) async {
    final doc = await firestore.collection('ride_drivers').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return RideDriverModel.fromMap(doc.data()!);
  }
}
