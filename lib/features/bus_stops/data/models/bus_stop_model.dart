import 'package:cloud_firestore/cloud_firestore.dart';

class BusStopModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final Timestamp createdAt;

  const BusStopModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
    };
  }

  factory BusStopModel.fromMap(String id, Map<String, dynamic> map) {
    return BusStopModel(
      id: id,
      name: map['name'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
