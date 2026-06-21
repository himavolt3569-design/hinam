import 'package:cloud_firestore/cloud_firestore.dart';

class BusLocationModel {
  final String driverId;
  final String busNumber;
  final String busType;
  final String? routeName;
  final String? schoolName;
  final double latitude;
  final double longitude;
  final double speed;
  final bool isTracking;
  final int studentCount;
  final Timestamp updatedAt;

  const BusLocationModel({
    required this.driverId,
    required this.busNumber,
    required this.busType,
    this.routeName,
    this.schoolName,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.isTracking,
    this.studentCount = 0,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'busNumber': busNumber,
      'busType': busType,
      'routeName': routeName,
      'schoolName': schoolName,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'isTracking': isTracking,
      'studentCount': studentCount,
      'updatedAt': updatedAt,
    };
  }

  factory BusLocationModel.fromMap(Map<String, dynamic> map) {
    return BusLocationModel(
      driverId: map['driverId'] ?? '',
      busNumber: map['busNumber'] ?? '',
      busType: map['busType'] ?? '',
      routeName: map['routeName'],
      schoolName: map['schoolName'],
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      speed: (map['speed'] ?? 0.0).toDouble(),
      isTracking: map['isTracking'] ?? false,
      studentCount: map['studentCount'] ?? 0,
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
