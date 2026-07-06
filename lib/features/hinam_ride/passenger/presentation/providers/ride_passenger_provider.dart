import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/passenger/data/datasources/ride_passenger_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/passenger/data/repositories/ride_passenger_repository.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final ridePassengerDatasourceProvider =
    Provider<RidePassengerRemoteDatasource>(
  (ref) => RidePassengerRemoteDatasource(ref.read(firestoreProvider)),
);

final ridePassengerRepositoryProvider = Provider<RidePassengerRepository>(
  (ref) => RidePassengerRepository(ref.read(ridePassengerDatasourceProvider)),
);
