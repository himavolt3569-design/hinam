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
        .where('status', isEqualTo: 'requested')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return RideModel.fromMap(doc.id, doc.data());
        });
  }

  Future<void> cancelRide(String rideId) async {
    await firestore.collection('rides').doc(rideId).update({
      'status': 'cancelled',
    });
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
              .map((doc) => RideOfferModel.fromMap(doc.id, doc.data()))
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
}
