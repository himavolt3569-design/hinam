import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/bus_stops/data/datasources/bus_stop_remote_datasource.dart';
import 'package:hinam/features/bus_stops/data/models/bus_stop_model.dart';

final busStopRepositoryProvider = Provider<BusStopRepository>((ref) {
  return BusStopRepository(BusStopRemoteDatasource(FirebaseFirestore.instance));
});

class BusStopRepository {
  final BusStopRemoteDatasource datasource;

  BusStopRepository(this.datasource);

  Stream<List<BusStopModel>> watchBusStops() => datasource.watchBusStops();

  Future<void> addBusStop({
    required String name,
    required double latitude,
    required double longitude,
  }) {
    final stop = BusStopModel(
      id: '',
      name: name,
      latitude: latitude,
      longitude: longitude,
      createdAt: Timestamp.now(),
    );

    return datasource.addBusStop(stop);
  }

  Future<void> deleteBusStop(String id) => datasource.deleteBusStop(id);
}
