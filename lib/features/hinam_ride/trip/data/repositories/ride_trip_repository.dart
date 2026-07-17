import 'package:hinam/features/hinam_ride/trip/data/datasources/ride_trip_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_offer_model.dart';

class RideTripRepository {
  final RideTripRemoteDatasource datasource;

  RideTripRepository(this.datasource);

  Future<String> createRide(RideModel ride) {
    return datasource.createRide(ride);
  }

  Stream<RideModel?> watchActiveRideForPassenger(String passengerId) {
    return datasource.watchActiveRideForPassenger(passengerId);
  }

  Stream<RideModel?> watchRide(String rideId) {
    return datasource.watchRide(rideId);
  }

  Future<void> cancelRide(
    String rideId, {
    required String cancelledBy,
    String? cancelReason,
  }) {
    return datasource.cancelRide(
      rideId,
      cancelledBy: cancelledBy,
      cancelReason: cancelReason,
    );
  }

  Future<void> markArrived(String rideId) {
    return datasource.markArrived(rideId);
  }

  Future<void> startTrip(String rideId) {
    return datasource.startTrip(rideId);
  }

  Future<void> completeTrip(String rideId) {
    return datasource.completeTrip(rideId);
  }

  Future<void> markNoShow(String rideId) {
    return datasource.markNoShow(rideId);
  }

  Future<void> submitRating({
    required String rideId,
    required bool isDriver,
    required double rating,
    String? comment,
  }) {
    return datasource.submitRating(
      rideId: rideId,
      isDriver: isDriver,
      rating: rating,
      comment: comment,
    );
  }

  Stream<List<RideModel>> watchRideHistory({
    required String uid,
    required bool isDriver,
  }) {
    return datasource.watchRideHistory(uid: uid, isDriver: isDriver);
  }

  Future<void> createOffer(String rideId, RideOfferModel offer) {
    return datasource.createOffer(rideId, offer);
  }

  Stream<List<RideOfferModel>> watchOffersForRide(String rideId) {
    return datasource.watchOffersForRide(rideId);
  }

  Future<void> expireOffer(String rideId, String offerId) {
    return datasource.expireOffer(rideId, offerId);
  }

  Stream<List<RideOfferModel>> watchPendingOffersForDriver(String driverId) {
    return datasource.watchPendingOffersForDriver(driverId);
  }

  Future<void> declineOffer(String rideId, String offerId) {
    return datasource.declineOffer(rideId, offerId);
  }

  Future<void> counterOffer({
    required String rideId,
    required String offerId,
    required double amount,
  }) {
    return datasource.counterOffer(
      rideId: rideId,
      offerId: offerId,
      amount: amount,
    );
  }

  Future<void> acceptOffer({
    required String rideId,
    required String offerId,
    required String driverId,
  }) {
    return datasource.acceptOffer(
      rideId: rideId,
      offerId: offerId,
      driverId: driverId,
    );
  }
}
