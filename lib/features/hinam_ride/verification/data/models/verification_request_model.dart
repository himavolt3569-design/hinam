import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationSubjectType {
  driver,
  passenger;

  static VerificationSubjectType fromValue(String value) {
    return VerificationSubjectType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => VerificationSubjectType.driver,
    );
  }
}

enum VerificationStatus {
  pending,
  approved,
  rejected;

  static VerificationStatus fromValue(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

class VerificationRequestModel {
  final String id;
  final VerificationSubjectType subjectType;
  final String subjectId;
  final Map<String, String> documentUrls;
  final VerificationStatus status;
  final String? reviewedBy;
  final Timestamp? reviewedAt;
  final String? rejectionReason;
  final Timestamp createdAt;

  const VerificationRequestModel({
    required this.id,
    required this.subjectType,
    required this.subjectId,
    required this.documentUrls,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectType': subjectType.name,
      'subjectId': subjectId,
      'documentUrls': documentUrls,
      'status': status.name,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt,
    };
  }

  factory VerificationRequestModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return VerificationRequestModel(
      id: id,
      subjectType: VerificationSubjectType.fromValue(
        map['subjectType'] ?? 'driver',
      ),
      subjectId: map['subjectId'] ?? '',
      documentUrls: Map<String, String>.from(map['documentUrls'] ?? {}),
      status: VerificationStatus.fromValue(map['status'] ?? 'pending'),
      reviewedBy: map['reviewedBy'],
      reviewedAt: map['reviewedAt'],
      rejectionReason: map['rejectionReason'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
