import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:hinam/features/hinam_ride/driver/data/datasources/ride_location_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/driver/data/models/ride_location_model.dart';

class RideTrackingRepository {
  final RideLocationRemoteDatasource datasource;

  RideTrackingRepository(this.datasource);

  Future<void> updateLocation({
    required String driverId,
    required Position position,
  }) async {
    final model = RideLocationModel(
      driverId: driverId,
      latitude: position.latitude,
      longitude: position.longitude,
      speed: position.speed,
      isOnline: true,
      updatedAt: Timestamp.now(),
    );
    await datasource.updateLocation(model);
  }

  Future<void> stopTracking(String driverId) async {
    await datasource.clearLocation(driverId);
  }
}
