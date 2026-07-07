import 'package:cloud_firestore/cloud_firestore.dart';

enum RideOfferStatus {
  pending,
  accepted,
  declined,
  expired;

  static RideOfferStatus fromValue(String value) {
    return RideOfferStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RideOfferStatus.pending,
    );
  }
}

class RideOfferModel {
  final String id;
  final String driverId;
  final double offerAmount;
  final RideOfferStatus status;
  final Timestamp createdAt;

  const RideOfferModel({
    required this.id,
    required this.driverId,
    required this.offerAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'offerAmount': offerAmount,
      'status': status.name,
      'createdAt': createdAt,
    };
  }

  factory RideOfferModel.fromMap(String id, Map<String, dynamic> map) {
    return RideOfferModel(
      id: id,
      driverId: map['driverId'] ?? '',
      offerAmount: (map['offerAmount'] ?? 0.0).toDouble(),
      status: RideOfferStatus.fromValue(map['status'] ?? 'pending'),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
