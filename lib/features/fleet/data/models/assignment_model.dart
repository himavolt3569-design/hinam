import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String busId;
  final String driverId;
  final String driverName;
  final String busNumber;
  final String busType;
  final String? routeName;
  final String? schoolName;
  final String shift; // 'morning' | 'afternoon' | 'full'
  final String date; // YYYY-MM-DD
  final String status; // 'active' | 'completed' | 'cancelled'
  final Timestamp createdAt;

  const AssignmentModel({
    required this.id,
    required this.busId,
    required this.driverId,
    required this.driverName,
    required this.busNumber,
    required this.busType,
    this.routeName,
    this.schoolName,
    required this.shift,
    required this.date,
    required this.status,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  String get routeOrSchool => routeName ?? schoolName ?? '';

  String get shiftLabel {
    switch (shift) {
      case 'morning':
        return 'Morning';
      case 'afternoon':
        return 'Afternoon';
      default:
        return 'Full Day';
    }
  }

  Map<String, dynamic> toMap() => {
        'busId': busId,
        'driverId': driverId,
        'driverName': driverName,
        'busNumber': busNumber,
        'busType': busType,
        'routeName': routeName,
        'schoolName': schoolName,
        'shift': shift,
        'date': date,
        'status': status,
        'createdAt': createdAt,
      };

  factory AssignmentModel.fromMap(String id, Map<String, dynamic> map) {
    return AssignmentModel(
      id: id,
      busId: map['busId'] ?? '',
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      busNumber: map['busNumber'] ?? '',
      busType: map['busType'] ?? 'public',
      routeName: map['routeName'],
      schoolName: map['schoolName'],
      shift: map['shift'] ?? 'full',
      date: map['date'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
