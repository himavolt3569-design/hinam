import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/shared/geo_utils.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_offer_model.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';
import 'active_ride_provider.dart';

final matchingServiceProvider =
    NotifierProvider<MatchingServiceNotifier, void>(
      MatchingServiceNotifier.new,
    );

class MatchingServiceNotifier extends Notifier<void> {
  static const defaultOfferTimeout = Duration(seconds: 20);

  StreamSubscription<List<RideOfferModel>>? _offersSubscription;
  Timer? _timeoutTimer;
  final Set<String> _excludedDriverIds = {};
  bool _isActive = false;

  @override
  void build() {
    ref.onDispose(() {
      _isActive = false;
      _offersSubscription?.cancel();
      _timeoutTimer?.cancel();
    });
  }

  /// Offers the ride to the nearest online driver, then watches the offer:
  /// - if it's declined, the next-nearest driver is offered immediately.
  /// - if it's still pending once [offerTimeout] elapses, it's marked
  ///   expired and the next-nearest driver is offered instead.
  /// - if it's accepted (the ride is matched), matching stops.
  /// - if it's countered, matching pauses: the passenger must respond
  ///   before escalation resumes (no such response flow exists yet).
  Future<void> startMatching({
    required String rideId,
    required String passengerId,
    required RideLocation pickup,
    required RideLocation dropoff,
    required double suggestedFare,
    Duration offerTimeout = defaultOfferTimeout,
  }) async {
    _excludedDriverIds
      ..clear()
      ..add(passengerId);
    _isActive = true;

    await _offerNextDriver(
      rideId: rideId,
      pickup: pickup,
      dropoff: dropoff,
      suggestedFare: suggestedFare,
    );

    await _offersSubscription?.cancel();
    _offersSubscription = ref
        .read(rideTripRepositoryProvider)
        .watchOffersForRide(rideId)
        .listen((offers) {
          _timeoutTimer?.cancel();
          if (offers.isEmpty) return;

          final latest = offers.first;

          if (latest.status == RideOfferStatus.accepted) {
            unawaited(stopMatching());
            return;
          }

          if (latest.status == RideOfferStatus.declined) {
            _excludedDriverIds.add(latest.driverId);
            unawaited(
              _offerNextDriver(
                rideId: rideId,
                pickup: pickup,
                dropoff: dropoff,
                suggestedFare: suggestedFare,
              ),
            );
            return;
          }

          if (latest.status != RideOfferStatus.pending) return;

          _timeoutTimer = Timer(offerTimeout, () async {
            if (!_isActive) return;

            try {
              await ref
                  .read(rideTripRepositoryProvider)
                  .expireOffer(rideId, latest.id);
              if (!_isActive) return;

              _excludedDriverIds.add(latest.driverId);
              await _offerNextDriver(
                rideId: rideId,
                pickup: pickup,
                dropoff: dropoff,
                suggestedFare: suggestedFare,
              );
            } catch (_) {
              // Best-effort escalation: if expiring or re-offering fails (e.g.
              // the ride was cancelled concurrently), there is no UI surface
              // watching this background timer, so fail silently rather than
              // crash on an unhandled Future error.
            }
          });
        });
  }

  Future<void> stopMatching() async {
    _isActive = false;
    await _offersSubscription?.cancel();
    _offersSubscription = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _excludedDriverIds.clear();
  }

  Future<bool> _offerNextDriver({
    required String rideId,
    required RideLocation pickup,
    required RideLocation dropoff,
    required double suggestedFare,
  }) async {
    final nearestDriverId = await _findNearestAvailableDriver(pickup);
    if (nearestDriverId == null) return false;

    final offer = RideOfferModel(
      id: '',
      rideId: rideId,
      driverId: nearestDriverId,
      pickup: pickup,
      dropoff: dropoff,
      offerAmount: suggestedFare,
      status: RideOfferStatus.pending,
      createdAt: Timestamp.now(),
    );

    await ref.read(rideTripRepositoryProvider).createOffer(rideId, offer);
    return true;
  }

  Future<String?> _findNearestAvailableDriver(RideLocation pickup) async {
    final snapshot = await ref
        .read(firestoreProvider)
        .collection('ride_locations')
        .where('isOnline', isEqualTo: true)
        .get();

    String? nearestDriverId;
    double? nearestDistance;

    for (final doc in snapshot.docs) {
      if (_excludedDriverIds.contains(doc.id)) continue;

      final data = doc.data();
      final distance = distanceInKm(
        fromLatitude: pickup.latitude,
        fromLongitude: pickup.longitude,
        toLatitude: (data['latitude'] ?? 0.0).toDouble(),
        toLongitude: (data['longitude'] ?? 0.0).toDouble(),
      );

      if (nearestDistance == null || distance < nearestDistance) {
        nearestDistance = distance;
        nearestDriverId = doc.id;
      }
    }

    return nearestDriverId;
  }
}
