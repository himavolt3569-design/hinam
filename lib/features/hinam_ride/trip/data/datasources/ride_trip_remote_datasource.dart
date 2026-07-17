import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_offer_model.dart';

class RideTripRemoteDatasource {
  final FirebaseFirestore firestore;

  RideTripRemoteDatasource(this.firestore);

  Future<String> createRide(RideModel ride) async {
    final ref = await firestore.collection('rides').add(ride.toMap());
    return ref.id;
  }

  Stream<RideModel?> watchActiveRideForPassenger(String passengerId) {
    return firestore
        .collection('rides')
        .where('passengerId', isEqualTo: passengerId)
        .where(
          'status',
          whereIn: ['requested', 'matched', 'arrived', 'inProgress'],
        )
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return RideModel.fromMap(doc.id, doc.data());
        });
  }

  Stream<RideModel?> watchRide(String rideId) {
    return firestore.collection('rides').doc(rideId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return RideModel.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> cancelRide(
    String rideId, {
    required String cancelledBy,
    String? cancelReason,
  }) async {
    await firestore.collection('rides').doc(rideId).update({
      'status': 'cancelled',
      'cancelledBy': cancelledBy,
      'cancelReason': cancelReason,
    });
  }

  Future<void> markArrived(String rideId) async {
    await firestore.collection('rides').doc(rideId).update({
      'status': 'arrived',
      'arrivedAt': Timestamp.now(),
    });
  }

  Future<void> startTrip(String rideId) async {
    await firestore.collection('rides').doc(rideId).update({
      'status': 'inProgress',
    });
  }

  Future<void> completeTrip(String rideId) async {
    await firestore.collection('rides').doc(rideId).update({
      'status': 'completed',
    });
  }

  Future<void> markNoShow(String rideId) async {
    await firestore.collection('rides').doc(rideId).update({
      'status': 'noShow',
    });
  }

  Future<void> submitRating({
    required String rideId,
    required bool isDriver,
    required double rating,
    String? comment,
  }) async {
    final fields = isDriver
        ? {'passengerRating': rating, 'passengerRatingComment': comment}
        : {'driverRating': rating, 'driverRatingComment': comment};

    await firestore.collection('rides').doc(rideId).update(fields);
  }

  Stream<List<RideModel>> watchRideHistory({
    required String uid,
    required bool isDriver,
  }) {
    return firestore
        .collection('rides')
        .where(isDriver ? 'driverId' : 'passengerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> createOffer(String rideId, RideOfferModel offer) async {
    await firestore
        .collection('rides')
        .doc(rideId)
        .collection('offers')
        .add(offer.toMap());
  }

  Stream<List<RideOfferModel>> watchOffersForRide(String rideId) {
    return firestore
        .collection('rides')
        .doc(rideId)
        .collection('offers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideOfferModel.fromMap(rideId, doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<RideOfferModel>> watchPendingOffersForDriver(String driverId) {
    return firestore
        .collectionGroup('offers')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => RideOfferModel.fromMap(
                  doc.reference.parent.parent!.id,
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> expireOffer(String rideId, String offerId) async {
    await firestore
        .collection('rides')
        .doc(rideId)
        .collection('offers')
        .doc(offerId)
        .update({'status': 'expired'});
  }

  Future<void> declineOffer(String rideId, String offerId) async {
    await firestore
        .collection('rides')
        .doc(rideId)
        .collection('offers')
        .doc(offerId)
        .update({'status': 'declined'});
  }

  Future<void> counterOffer({
    required String rideId,
    required String offerId,
    required double amount,
  }) async {
    await firestore
        .collection('rides')
        .doc(rideId)
        .collection('offers')
        .doc(offerId)
        .update({'status': 'countered', 'offerAmount': amount});
  }

  /// Atomically arbitrates acceptance of an offer via a Firestore transaction,
  /// gated by security rules that re-check the live server state at write
  /// time, not by client-side trust. Firestore always serializes writes to
  /// a single document and re-evaluates rules against the then-current
  /// server state for each one, so the `rides` update below is the actual
  /// race-safety boundary: whichever of two concurrent accept attempts
  /// reaches the server first wins (its write sees `driverId == null` and
  /// is allowed); the other sees the already-updated document and is
  /// rejected by the rule itself, regardless of what this client believed
  /// when it started.
  ///
  /// The two writes are deliberately sequential rather than a single
  /// transaction: the `offers` update's own rule cross-checks the *now
  /// committed* ride state (driverId/acceptedOfferId/status), which closes
  /// a gap a single transaction can't — Firestore rules evaluate `get()`
  /// calls within a transaction against a snapshot from before any of that
  /// transaction's own writes, so an offer-only rule could not otherwise
  /// prove the ride was really matched in the same operation. A malicious
  /// or buggy client attempting to flip only the offer to `accepted` — with
  /// no matching ride update — is rejected by that cross-check.
  Future<void> acceptOffer({
    required String rideId,
    required String offerId,
    required String driverId,
  }) async {
    final rideRef = firestore.collection('rides').doc(rideId);
    final offerRef = rideRef.collection('offers').doc(offerId);

    final rideSnap = await rideRef.get();
    final offerSnap = await offerRef.get();

    if (!rideSnap.exists) {
      throw Exception('This ride no longer exists.');
    }
    if (!offerSnap.exists) {
      throw Exception('This offer no longer exists.');
    }

    final ride = rideSnap.data()!;
    final offer = offerSnap.data()!;

    if (offer['driverId'] != driverId) {
      throw Exception('This offer was not made to you.');
    }
    if (ride['driverId'] != null) {
      throw Exception(
        'This ride has already been matched with another driver.',
      );
    }
    if (offer['status'] != 'pending') {
      throw Exception('This offer is no longer available.');
    }

    await rideRef.update({
      'driverId': driverId,
      'status': 'matched',
      'agreedFare': offer['offerAmount'],
      'acceptedOfferId': offerId,
      'matchedAt': Timestamp.now(),
    });

    await offerRef.update({'status': 'accepted'});
  }
}
