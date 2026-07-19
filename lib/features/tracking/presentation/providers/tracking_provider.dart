import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hinam/features/driver/presentation/providers/driver_profile_provider.dart';
import 'package:hinam/features/fleet/presentation/providers/fleet_providers.dart';
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
  TrackingState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const TrackingState(isTracking: false);
  }

  Future<void> startTracking() async {
    if (state.isTracking) return;

    final driver = ref.read(driverProfileProvider).asData?.value;
    if (driver == null) return;

    // Verify permission by getting a single position first — throws if denied
    await ref.read(locationServiceProvider).getCurrentLocation();

    // Two-tier by design: a driver's self-registered bus/route is their default;
    // an admin's fleet assignment for today overrides it when present.
    final assignment = ref.read(activeAssignmentProvider).asData?.value;
    final busNumber = assignment?.busNumber ?? driver.busNumber;
    final busType = assignment?.busType ?? driver.busType;
    final routeName = assignment?.routeName ?? driver.routeName;
    final schoolName = assignment?.schoolName ?? driver.schoolName;

    state = state.copyWith(isTracking: true, studentCount: 0);

    _subscription = ref
        .read(locationServiceProvider)
        .getLocationStream()
        .listen((position) async {
          state = state.copyWith(isTracking: true, position: position);

          await ref
              .read(trackingRepositoryProvider)
              .updateLocation(
                driverId: driver.uid,
                driverName: driver.fullName,
                busNumber: busNumber,
                busType: busType,
                routeName: routeName,
                schoolName: schoolName,
                position: position,
                studentCount: state.studentCount,
              );
        }, onError: (_) => stopTracking());
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
