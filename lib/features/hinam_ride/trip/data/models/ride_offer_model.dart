import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';

enum RideOfferStatus {
  pending,
  accepted,
  declined,
  countered,
  expired;

  static RideOfferStatus fromValue(String value) {
    return RideOfferStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RideOfferStatus.pending,
    );
  }
}

class RideOfferModel {
  final String id;
  final String rideId;
  final String driverId;
  final RideLocation pickup;
  final RideLocation dropoff;
  final double offerAmount;
  final RideOfferStatus status;
  final Timestamp createdAt;

  const RideOfferModel({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.pickup,
    required this.dropoff,
    required this.offerAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'pickup': pickup.toMap(),
      'dropoff': dropoff.toMap(),
      'offerAmount': offerAmount,
      'status': status.name,
      'createdAt': createdAt,
    };
  }

  factory RideOfferModel.fromMap(
    String rideId,
    String id,
    Map<String, dynamic> map,
  ) {
    return RideOfferModel(
      id: id,
      rideId: rideId,
      driverId: map['driverId'] ?? '',
      pickup: RideLocation.fromMap(
        Map<String, dynamic>.from(map['pickup'] ?? {}),
      ),
      dropoff: RideLocation.fromMap(
        Map<String, dynamic>.from(map['dropoff'] ?? {}),
      ),
      offerAmount: (map['offerAmount'] ?? 0.0).toDouble(),
      status: RideOfferStatus.fromValue(map['status'] ?? 'pending'),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
