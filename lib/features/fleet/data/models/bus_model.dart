import 'package:cloud_firestore/cloud_firestore.dart';

class BusModel {
  final String id;
  final String busNumber;
  final String busType; // 'public' | 'school'
  final String? routeName;
  final String? schoolName;
  final Timestamp createdAt;

  const BusModel({
    required this.id,
    required this.busNumber,
    required this.busType,
    this.routeName,
    this.schoolName,
    required this.createdAt,
  });

  bool get isPublic => busType == 'public';
  String get routeOrSchool => routeName ?? schoolName ?? '';

  Map<String, dynamic> toMap() => {
        'busNumber': busNumber,
        'busType': busType,
        'routeName': routeName,
        'schoolName': schoolName,
        'createdAt': createdAt,
      };

  factory BusModel.fromMap(String id, Map<String, dynamic> map) {
    return BusModel(
      id: id,
      busNumber: map['busNumber'] ?? '',
      busType: map['busType'] ?? 'public',
      routeName: map['routeName'],
      schoolName: map['schoolName'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
