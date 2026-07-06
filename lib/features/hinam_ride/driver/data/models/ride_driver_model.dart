import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart'
    show VerificationStatus;

class RideDriverModel {
  final String uid;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final DateTime dateOfBirth;
  final String vehicleType;
  final String vehiclePlate;
  final String licenseNumber;
  final VerificationStatus verificationStatus;
  final bool isOnline;
  final double ratingAvg;
  final int totalRides;
  final Timestamp createdAt;

  const RideDriverModel({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.licenseNumber,
    required this.verificationStatus,
    required this.isOnline,
    required this.ratingAvg,
    required this.totalRides,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'licenseNumber': licenseNumber,
      'verificationStatus': verificationStatus.name,
      'isOnline': isOnline,
      'ratingAvg': ratingAvg,
      'totalRides': totalRides,
      'createdAt': createdAt,
    };
  }

  factory RideDriverModel.fromMap(Map<String, dynamic> map) {
    return RideDriverModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      gender: map['gender'] ?? '',
      dateOfBirth:
          (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime(2000, 1, 1),
      vehicleType: map['vehicleType'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      verificationStatus:
          VerificationStatus.fromValue(map['verificationStatus'] ?? 'pending'),
      isOnline: map['isOnline'] ?? false,
      ratingAvg: (map['ratingAvg'] ?? 0.0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
