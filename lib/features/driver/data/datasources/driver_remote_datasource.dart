import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/driver/data/models/driver_model.dart';

class DriverRemoteDatasource {
  final FirebaseFirestore firestore;

  DriverRemoteDatasource(this.firestore);

  Future<bool> driverExists(String uid) async {
    final doc = await firestore.collection('drivers').doc(uid).get();

    return doc.exists;
  }

  Future<void> createDriver(DriverModel driver) async {
    await firestore.collection('drivers').doc(driver.uid).set(driver.toMap());
  }

  Future<DriverModel?> getDriver(String uid) async {
    final doc = await firestore.collection('drivers').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return DriverModel.fromMap(doc.data()!);
  }
}
