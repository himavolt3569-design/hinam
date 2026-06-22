import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/driver/data/datasources/driver_remote_datasource.dart';
import 'package:hinam/features/driver/data/repositories/driver_repository.dart';

final driverFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final driverDatasourceProvider = Provider<DriverRemoteDatasource>(
  (ref) => DriverRemoteDatasource(ref.read(driverFirestoreProvider)),
);

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => DriverRepository(ref.read(driverDatasourceProvider)),
);
