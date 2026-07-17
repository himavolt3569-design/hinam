import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod {
  cash;

  static PaymentMethod fromValue(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

enum RideTransactionStatus {
  completed;

  static RideTransactionStatus fromValue(String value) {
    return RideTransactionStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RideTransactionStatus.completed,
    );
  }
}

class RideTransactionModel {
  final String id;
  final String rideId;
  final String payerId;
  final String payeeId;
  final double amount;
  final PaymentMethod method;
  final RideTransactionStatus status;
  final Timestamp createdAt;

  const RideTransactionModel({
    required this.id,
    required this.rideId,
    required this.payerId,
    required this.payeeId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'payerId': payerId,
      'payeeId': payeeId,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'createdAt': createdAt,
    };
  }

  factory RideTransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return RideTransactionModel(
      id: id,
      rideId: map['rideId'] ?? '',
      payerId: map['payerId'] ?? '',
      payeeId: map['payeeId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      method: PaymentMethod.fromValue(map['method'] ?? 'cash'),
      status: RideTransactionStatus.fromValue(map['status'] ?? 'completed'),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
