import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/driver/data/datasources/driver_remote_datasource.dart';
import 'package:hinam/features/driver/data/repositories/driver_repository.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final driverDatasourceProvider = Provider<DriverRemoteDatasource>(
  (ref) => DriverRemoteDatasource(ref.read(firestoreProvider)),
);

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => DriverRepository(ref.read(driverDatasourceProvider)),
);
