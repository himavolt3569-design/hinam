import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/passenger/data/datasources/passenger_remote_datasource.dart';
import 'package:hinam/shared/models/bus_location_model.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final passengerRepositoryProvider = Provider<PassengerRepository>((ref) {
  return PassengerRepository(
    PassengerRemoteDatasource(ref.read(firestoreProvider)),
  );
});

class PassengerRepository {
  final PassengerRemoteDatasource datasource;

  PassengerRepository(this.datasource);

  Stream<List<BusLocationModel>> watchActiveBuses() {
    return datasource.watchActiveBuses();
  }

  Stream<BusLocationModel?> watchSingleBus(String driverId) {
    return datasource.watchSingleBus(driverId);
  }
}
