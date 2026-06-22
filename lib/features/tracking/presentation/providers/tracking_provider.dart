import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hinam/features/driver/presentation/providers/driver_profile_provider.dart';
import 'package:hinam/features/tracking/data/repositories/tracking_repository.dart';
import 'package:hinam/features/tracking/presentation/providers/tracking_state.dart';
import 'package:hinam/features/tracking/presentation/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final trackingProvider = NotifierProvider<TrackingNotifier, TrackingState>(
  TrackingNotifier.new,
);

class TrackingNotifier extends Notifier<TrackingState> {
  StreamSubscription? _subscription;

  @override
  TrackingState build() => const TrackingState(isTracking: false);

  Future<void> startTracking() async {
    if (state.isTracking) return;

    final driver = ref.read(driverProfileProvider).asData?.value;
    if (driver == null) return;

    state = state.copyWith(isTracking: true, studentCount: 0);

    _subscription = ref
        .read(locationServiceProvider)
        .getLocationStream()
        .listen((position) async {
          state = state.copyWith(isTracking: true, position: position);

          await ref
              .read(trackingRepositoryProvider)
              .updateLocation(
                driver: driver,
                position: position,
                studentCount: state.studentCount,
              );
        });
  }

  Future<void> stopTracking() async {
    _subscription?.cancel();
    _subscription = null;

    final driver = ref.read(driverProfileProvider).asData?.value;
    if (driver != null) {
      await ref.read(trackingRepositoryProvider).stopTracking(driver.uid);
    }

    state = const TrackingState(isTracking: false);
  }

  Future<void> incrementStudentCount() async {
    state = state.copyWith(studentCount: state.studentCount + 1);
    await _syncStudentCount();
  }

  Future<void> decrementStudentCount() async {
    if (state.studentCount <= 0) return;
    state = state.copyWith(studentCount: state.studentCount - 1);
    await _syncStudentCount();
  }

  Future<void> _syncStudentCount() async {
    final driver = ref.read(driverProfileProvider).asData?.value;
    if (driver == null || !state.isTracking) return;
    await ref
        .read(trackingRepositoryProvider)
        .updateStudentCount(driver.uid, state.studentCount);
  }
}
