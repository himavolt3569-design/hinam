import 'package:cloud_firestore/cloud_firestore.dart';

class RideLocationModel {
  final String driverId;
  final double latitude;
  final double longitude;
  final double speed;
  final bool isOnline;
  final Timestamp updatedAt;

  const RideLocationModel({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.isOnline,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'isOnline': isOnline,
      'updatedAt': updatedAt,
    };
  }

  factory RideLocationModel.fromMap(Map<String, dynamic> map) {
    return RideLocationModel(
      driverId: map['driverId'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      speed: (map['speed'] ?? 0.0).toDouble(),
      isOnline: map['isOnline'] ?? false,
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
