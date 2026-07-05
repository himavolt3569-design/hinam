import 'package:cloud_firestore/cloud_firestore.dart';

class BusLocationModel {
  final String driverId;
  final String driverName;
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
    this.driverName = '',
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

  String get routeOrSchool => routeName ?? schoolName ?? '';

  /// [speed] is in meters/second (as reported by geolocator); convert for display.
  double get speedKmh => speed * 3.6;

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
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
      driverName: map['driverName'] ?? '',
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
