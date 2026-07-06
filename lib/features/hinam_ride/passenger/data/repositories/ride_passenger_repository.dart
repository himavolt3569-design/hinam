import 'package:hinam/features/hinam_ride/passenger/data/datasources/ride_passenger_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/passenger/data/models/ride_passenger_model.dart';

class RidePassengerRepository {
  final RidePassengerRemoteDatasource datasource;

  RidePassengerRepository(this.datasource);

  Future<bool> passengerExists(String uid) {
    return datasource.passengerExists(uid);
  }

  Future<void> createPassenger(RidePassengerModel passenger) {
    return datasource.createPassenger(passenger);
  }

  Future<RidePassengerModel?> getPassenger(String uid) {
    return datasource.getPassenger(uid);
  }
}
