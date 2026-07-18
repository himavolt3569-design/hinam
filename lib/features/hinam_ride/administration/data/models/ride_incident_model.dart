import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart'
    show RideLocation;

enum RideIncidentStatus {
  open,
  acknowledged,
  resolved;

  static RideIncidentStatus fromValue(String value) {
    return RideIncidentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RideIncidentStatus.open,
    );
  }
}

class RideIncidentModel {
  final String id;
  final String rideId;
  final String triggeredBy;
  final RideLocation location;
  final RideIncidentStatus status;
  final Timestamp createdAt;
  final String? acknowledgedBy;

  const RideIncidentModel({
    required this.id,
    required this.rideId,
    required this.triggeredBy,
    required this.location,
    required this.status,
    required this.createdAt,
    this.acknowledgedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'triggeredBy': triggeredBy,
      'location': location.toMap(),
      'status': status.name,
      'createdAt': createdAt,
      'acknowledgedBy': acknowledgedBy,
    };
  }

  factory RideIncidentModel.fromMap(String id, Map<String, dynamic> map) {
    return RideIncidentModel(
      id: id,
      rideId: map['rideId'] ?? '',
      triggeredBy: map['triggeredBy'] ?? '',
      location: RideLocation.fromMap(
        Map<String, dynamic>.from(map['location'] ?? {}),
      ),
      status: RideIncidentStatus.fromValue(map['status'] ?? 'open'),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      acknowledgedBy: map['acknowledgedBy'],
    );
  }
}
