import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

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
}
