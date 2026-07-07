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

  Future<void> cancelRide(String rideId) {
    return datasource.cancelRide(rideId);
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
}
