import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:hinam/features/tracking/data/datasources/tracking_remote_datasource.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository(TrackingRemoteDatasource(FirebaseFirestore.instance));
});

class TrackingRepository {
  final TrackingRemoteDatasource datasource;

  TrackingRepository(this.datasource);

  Future<void> updateLocation({
    required String driverId,
    required String driverName,
    required String busNumber,
    required String busType,
    String? routeName,
    String? schoolName,
    required Position position,
    required int studentCount,
  }) async {
    final model = BusLocationModel(
      driverId: driverId,
      driverName: driverName,
      busNumber: busNumber,
      busType: busType,
      routeName: routeName,
      schoolName: schoolName,
      latitude: position.latitude,
      longitude: position.longitude,
      speed: position.speed,
      isTracking: true,
      studentCount: studentCount,
      updatedAt: Timestamp.now(),
    );
    await datasource.updateBusLocation(model);
  }

  Future<void> updateStudentCount(String driverId, int count) {
    return datasource.updateStudentCount(driverId, count);
  }

  Future<void> stopTracking(String driverId) async {
    await datasource.clearBusLocation(driverId);
  }
}
