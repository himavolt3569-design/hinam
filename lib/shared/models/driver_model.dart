import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final String uid;
  final String fullName;
  final String phoneNumber;

  final String busNumber;
  final String busType;

  final String? routeName;
  final String? schoolName;

  final bool isApproved;

  final Timestamp createdAt;

  const DriverModel({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.busNumber,
    required this.busType,
    this.routeName,
    this.schoolName,
    required this.isApproved,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'busNumber': busNumber,
      'busType': busType,
      'routeName': routeName,
      'schoolName': schoolName,
      'isApproved': isApproved,
      'createdAt': createdAt,
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      busNumber: map['busNumber'] ?? '',
      busType: map['busType'] ?? '',
      routeName: map['routeName'],
      schoolName: map['schoolName'],
      isApproved: map['isApproved'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
