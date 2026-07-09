import 'package:cloud_firestore/cloud_firestore.dart';

class RideLocation {
  final double latitude;
  final double longitude;
  final String address;

  const RideLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }

  factory RideLocation.fromMap(Map<String, dynamic> map) {
    return RideLocation(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
    );
  }
}

enum RideStatus {
  requested,
  matched,
  cancelled;

  static RideStatus fromValue(String value) {
    return RideStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RideStatus.requested,
    );
  }
}

class RideModel {
  final String id;
  final String passengerId;
  final String? driverId;
  final RideLocation pickup;
  final RideLocation dropoff;
  final RideStatus status;
  final double suggestedFare;
  final double? agreedFare;
  final String? acceptedOfferId;
  final Timestamp createdAt;
  final Timestamp? matchedAt;

  const RideModel({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickup,
    required this.dropoff,
    required this.status,
    required this.suggestedFare,
    this.agreedFare,
    this.acceptedOfferId,
    required this.createdAt,
    this.matchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'driverId': driverId,
      'pickup': pickup.toMap(),
      'dropoff': dropoff.toMap(),
      'status': status.name,
      'suggestedFare': suggestedFare,
      'agreedFare': agreedFare,
      'acceptedOfferId': acceptedOfferId,
      'createdAt': createdAt,
      'matchedAt': matchedAt,
    };
  }

  factory RideModel.fromMap(String id, Map<String, dynamic> map) {
    return RideModel(
      id: id,
      passengerId: map['passengerId'] ?? '',
      driverId: map['driverId'],
      pickup: RideLocation.fromMap(
        Map<String, dynamic>.from(map['pickup'] ?? {}),
      ),
      dropoff: RideLocation.fromMap(
        Map<String, dynamic>.from(map['dropoff'] ?? {}),
      ),
      status: RideStatus.fromValue(map['status'] ?? 'requested'),
      suggestedFare: (map['suggestedFare'] ?? 0.0).toDouble(),
      agreedFare: (map['agreedFare'] as num?)?.toDouble(),
      acceptedOfferId: map['acceptedOfferId'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      matchedAt: map['matchedAt'],
    );
  }
}
