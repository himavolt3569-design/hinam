import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/passenger/data/datasources/passenger_remote_datasource.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

final passengerRepositoryProvider = Provider<PassengerRepository>((ref) {
  return PassengerRepository(
    PassengerRemoteDatasource(FirebaseFirestore.instance),
  );
});

class PassengerRepository {
  final PassengerRemoteDatasource datasource;

  PassengerRepository(this.datasource);

  Stream<List<BusLocationModel>> watchActiveBuses() {
    return datasource.watchActiveBuses();
  }
}
