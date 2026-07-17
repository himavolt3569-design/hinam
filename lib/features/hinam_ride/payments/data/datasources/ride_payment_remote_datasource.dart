import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/payments/data/models/ride_transaction_model.dart';

class RidePaymentRemoteDatasource {
  final FirebaseFirestore firestore;

  RidePaymentRemoteDatasource(this.firestore);

  Future<void> markPaid(RideTransactionModel transaction) async {
    await firestore
        .collection('ride_transactions')
        .doc(transaction.rideId)
        .set(transaction.toMap());
  }

  Stream<RideTransactionModel?> watchTransactionForRide(String rideId) {
    return firestore
        .collection('ride_transactions')
        .doc(rideId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return RideTransactionModel.fromMap(doc.id, doc.data()!);
        });
  }
}
