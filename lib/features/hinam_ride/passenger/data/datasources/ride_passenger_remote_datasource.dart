import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/passenger/data/models/ride_passenger_model.dart';

class RidePassengerRemoteDatasource {
  final FirebaseFirestore firestore;

  RidePassengerRemoteDatasource(this.firestore);

  Future<bool> passengerExists(String uid) async {
    final doc = await firestore.collection('ride_passengers').doc(uid).get();

    return doc.exists;
  }

  Future<void> createPassenger(RidePassengerModel passenger) async {
    await firestore
        .collection('ride_passengers')
        .doc(passenger.uid)
        .set(passenger.toMap());
  }

  Future<RidePassengerModel?> getPassenger(String uid) async {
    final doc = await firestore.collection('ride_passengers').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return RidePassengerModel.fromMap(doc.data()!);
  }
}
