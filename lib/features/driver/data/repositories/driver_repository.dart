import 'package:hinam/features/driver/data/datasources/driver_remote_datasource.dart';
import 'package:hinam/shared/models/driver_model.dart';

class DriverRepository {
  final DriverRemoteDatasource datasource;

  DriverRepository(this.datasource);

  Future<bool> driverExists(String uid) {
    return datasource.driverExists(uid);
  }

  Future<void> createDriver(DriverModel driver) {
    return datasource.createDriver(driver);
  }

  Future<DriverModel?> getDriver(String uid) {
    return datasource.getDriver(uid);
  }
}
