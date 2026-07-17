import 'package:cloud_firestore/cloud_firestore.dart';

enum RideReportStatus {
  open,
  reviewed,
  resolved;

  static RideReportStatus fromValue(String value) {
    return RideReportStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RideReportStatus.open,
    );
  }
}

class RideReportModel {
  final String id;
  final String rideId;
  final String reportedBy;
  final String reportedUserId;
  final String reason;
  final String details;
  final RideReportStatus status;
  final Timestamp createdAt;
  final String? reviewedBy;

  const RideReportModel({
    required this.id,
    required this.rideId,
    required this.reportedBy,
    required this.reportedUserId,
    required this.reason,
    required this.details,
    required this.status,
    required this.createdAt,
    this.reviewedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'reportedBy': reportedBy,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'details': details,
      'status': status.name,
      'createdAt': createdAt,
      'reviewedBy': reviewedBy,
    };
  }

  factory RideReportModel.fromMap(String id, Map<String, dynamic> map) {
    return RideReportModel(
      id: id,
      rideId: map['rideId'] ?? '',
      reportedBy: map['reportedBy'] ?? '',
      reportedUserId: map['reportedUserId'] ?? '',
      reason: map['reason'] ?? '',
      details: map['details'] ?? '',
      status: RideReportStatus.fromValue(map['status'] ?? 'open'),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      reviewedBy: map['reviewedBy'],
    );
  }
}
