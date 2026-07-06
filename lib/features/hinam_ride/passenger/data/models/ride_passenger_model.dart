import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart'
    show VerificationStatus;

class EmergencyContact {
  final String name;
  final String phone;

  const EmergencyContact({required this.name, required this.phone});

  Map<String, dynamic> toMap() {
    return {'name': name, 'phone': phone};
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}

class RidePassengerModel {
  static const int maxEmergencyContacts = 3;

  final String uid;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final VerificationStatus verificationStatus;
  final List<EmergencyContact> emergencyContacts;
  final double ratingAvg;
  final int totalRides;
  final Timestamp createdAt;

  const RidePassengerModel({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.verificationStatus,
    required this.emergencyContacts,
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
      'verificationStatus': verificationStatus.name,
      'emergencyContacts': emergencyContacts.map((c) => c.toMap()).toList(),
      'ratingAvg': ratingAvg,
      'totalRides': totalRides,
      'createdAt': createdAt,
    };
  }

  factory RidePassengerModel.fromMap(Map<String, dynamic> map) {
    return RidePassengerModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      gender: map['gender'] ?? '',
      verificationStatus: VerificationStatus.fromValue(
        map['verificationStatus'] ?? 'pending',
      ),
      emergencyContacts: ((map['emergencyContacts'] as List?) ?? [])
          .map(
            (contact) =>
                EmergencyContact.fromMap(Map<String, dynamic>.from(contact)),
          )
          .toList(),
      ratingAvg: (map['ratingAvg'] ?? 0.0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
