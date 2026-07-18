import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/hinam_ride/administration/data/datasources/ride_incident_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/administration/data/models/ride_incident_model.dart';
import 'package:hinam/features/hinam_ride/administration/data/repositories/ride_incident_repository.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart'
    show RideLocation;
import 'package:hinam/features/tracking/presentation/providers/tracking_provider.dart'
    show locationServiceProvider;
import 'package:hinam/shared/providers/firebase_providers.dart';

final rideIncidentDatasourceProvider = Provider<RideIncidentRemoteDatasource>(
  (ref) => RideIncidentRemoteDatasource(ref.read(firestoreProvider)),
);

final rideIncidentRepositoryProvider = Provider<RideIncidentRepository>(
  (ref) => RideIncidentRepository(ref.read(rideIncidentDatasourceProvider)),
);

final openIncidentsProvider = StreamProvider<List<RideIncidentModel>>((ref) {
  return ref.watch(rideIncidentRepositoryProvider).watchOpenIncidents();
});

final incidentTriggerControllerProvider =
    AsyncNotifierProvider<IncidentTriggerController, void>(
      IncidentTriggerController.new,
    );

class IncidentTriggerController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Returns the location used for the incident so the caller (the SOS button)
  // can reuse the same fix in its SMS fallback instead of requesting GPS twice.
  // Location is fetched before anything else so it is always available to
  // return, even if a later step (e.g. the Firestore write) fails.
  Future<RideLocation> triggerSos(String rideId) async {
    final location = await _currentLocationOrUnknown();

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final triggeredBy = ref
          .read(authControllerProvider.notifier)
          .currentUser()
          ?.uid;
      if (triggeredBy == null) {
        throw StateError('You must be signed in to trigger SOS.');
      }

      final incident = RideIncidentModel(
        id: '',
        rideId: rideId,
        triggeredBy: triggeredBy,
        location: location,
        status: RideIncidentStatus.open,
        createdAt: Timestamp.now(),
      );

      await ref.read(rideIncidentRepositoryProvider).createIncident(incident);
    });

    return location;
  }

  Future<RideLocation> _currentLocationOrUnknown() async {
    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      return RideLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address:
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
      );
    } catch (_) {
      return const RideLocation(latitude: 0, longitude: 0, address: 'Unknown');
    }
  }
}

final incidentReviewControllerProvider =
    AsyncNotifierProvider<IncidentReviewController, void>(
      IncidentReviewController.new,
    );

class IncidentReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> acknowledge(String incidentId) async {
    await _updateStatus(incidentId, RideIncidentStatus.acknowledged);
  }

  Future<void> resolve(String incidentId) async {
    await _updateStatus(incidentId, RideIncidentStatus.resolved);
  }

  Future<void> _updateStatus(
    String incidentId,
    RideIncidentStatus status,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final adminUid = ref
          .read(authControllerProvider.notifier)
          .currentUser()
          ?.uid;
      if (adminUid == null) {
        throw StateError('No authenticated admin.');
      }

      await ref
          .read(rideIncidentRepositoryProvider)
          .updateIncidentStatus(
            incidentId: incidentId,
            adminUid: adminUid,
            status: status,
          );
    });
  }
}
