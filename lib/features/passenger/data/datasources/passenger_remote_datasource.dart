import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/shared/models/bus_location_model.dart';

class PassengerRemoteDatasource {
  final FirebaseFirestore firestore;

  PassengerRemoteDatasource(this.firestore);

  Stream<List<BusLocationModel>> watchActiveBuses() {
    return firestore
        .collection('bus_locations')
        .where('isTracking', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BusLocationModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<BusLocationModel?> watchSingleBus(String driverId) {
    return firestore
        .collection('bus_locations')
        .doc(driverId)
        .snapshots()
        .map(
          (doc) => doc.exists ? BusLocationModel.fromMap(doc.data()!) : null,
        );
  }
}
