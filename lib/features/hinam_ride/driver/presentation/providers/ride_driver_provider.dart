import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/driver/data/datasources/ride_driver_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/driver/data/models/ride_driver_model.dart';
import 'package:hinam/features/hinam_ride/driver/data/repositories/ride_driver_repository.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final rideDriverDatasourceProvider = Provider<RideDriverRemoteDatasource>(
  (ref) => RideDriverRemoteDatasource(ref.read(firestoreProvider)),
);

final rideDriverRepositoryProvider = Provider<RideDriverRepository>(
  (ref) => RideDriverRepository(ref.read(rideDriverDatasourceProvider)),
);

final rideDriverByIdProvider = FutureProvider.family<RideDriverModel?, String>(
  (ref, uid) => ref.watch(rideDriverRepositoryProvider).getDriver(uid),
);
