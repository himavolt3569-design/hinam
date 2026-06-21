import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/bus_stops/data/models/bus_stop_model.dart';

class BusStopRemoteDatasource {
  final FirebaseFirestore firestore;

  BusStopRemoteDatasource(this.firestore);

  Stream<List<BusStopModel>> watchBusStops() {
    return firestore.collection('bus_stops').orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => BusStopModel.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Future<void> addBusStop(BusStopModel stop) async {
    await firestore.collection('bus_stops').add(stop.toMap());
  }

  Future<void> deleteBusStop(String id) async {
    await firestore.collection('bus_stops').doc(id).delete();
  }
}
