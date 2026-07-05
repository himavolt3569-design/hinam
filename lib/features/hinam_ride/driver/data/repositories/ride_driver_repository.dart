import 'package:hinam/features/hinam_ride/driver/data/datasources/ride_driver_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/driver/data/models/ride_driver_model.dart';

class RideDriverRepository {
  final RideDriverRemoteDatasource datasource;

  RideDriverRepository(this.datasource);

  Future<bool> driverExists(String uid) {
    return datasource.driverExists(uid);
  }

  Future<void> createDriver(RideDriverModel driver) {
    return datasource.createDriver(driver);
  }

  Future<RideDriverModel?> getDriver(String uid) {
    return datasource.getDriver(uid);
  }
}
