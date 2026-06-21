import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/bus_stops/data/models/bus_stop_model.dart';
import 'package:hinam/features/bus_stops/data/repositories/bus_stop_repository.dart';

final busStopsProvider = StreamProvider<List<BusStopModel>>((ref) {
  return ref.watch(busStopRepositoryProvider).watchBusStops();
});
