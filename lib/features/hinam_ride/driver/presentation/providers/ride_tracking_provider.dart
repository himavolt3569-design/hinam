import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:hinam/features/hinam_ride/driver/data/datasources/ride_location_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/driver/data/repositories/ride_tracking_repository.dart';
import 'package:hinam/features/tracking/presentation/providers/tracking_provider.dart'
    show locationServiceProvider;
import 'package:hinam/shared/providers/firebase_providers.dart';

final rideLocationDatasourceProvider = Provider<RideLocationRemoteDatasource>(
  (ref) => RideLocationRemoteDatasource(ref.read(firestoreProvider)),
);

final rideTrackingRepositoryProvider = Provider<RideTrackingRepository>(
  (ref) =>
      RideTrackingRepository(ref.read(rideLocationDatasourceProvider)),
);

class RideTrackingState {
  final bool isTracking;
  final Position? position;

  const RideTrackingState({required this.isTracking, this.position});

  RideTrackingState copyWith({bool? isTracking, Position? position}) {
    return RideTrackingState(
      isTracking: isTracking ?? this.isTracking,
      position: position ?? this.position,
    );
  }
}

final rideTrackingProvider =
    NotifierProvider<RideTrackingNotifier, RideTrackingState>(
      RideTrackingNotifier.new,
    );

class RideTrackingNotifier extends Notifier<RideTrackingState> {
  StreamSubscription? _subscription;

  @override
  RideTrackingState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const RideTrackingState(isTracking: false);
  }

  Future<void> startTracking(String driverId) async {
    if (state.isTracking) return;

    // Verify permission by getting a single position first — throws if denied.
    await ref.read(locationServiceProvider).getCurrentLocation();

    state = state.copyWith(isTracking: true);

    _subscription = ref
        .read(locationServiceProvider)
        .getLocationStream()
        .listen(
          (position) async {
            state = state.copyWith(isTracking: true, position: position);

            await ref
                .read(rideTrackingRepositoryProvider)
                .updateLocation(driverId: driverId, position: position);
          },
          onError: (_) => stopTracking(driverId),
        );
  }

  Future<void> stopTracking(String driverId) async {
    _subscription?.cancel();
    _subscription = null;

    await ref.read(rideTrackingRepositoryProvider).stopTracking(driverId);

    state = const RideTrackingState(isTracking: false);
  }
}
