import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/bus_stops/data/repositories/bus_stop_repository.dart';

final busStopControllerProvider =
    AsyncNotifierProvider<BusStopController, void>(BusStopController.new);

class BusStopController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addStop({
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(busStopRepositoryProvider).addBusStop(
            name: name,
            latitude: latitude,
            longitude: longitude,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteStop(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(busStopRepositoryProvider).deleteBusStop(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
