import 'package:hinam/features/hinam_ride/payments/data/datasources/ride_payment_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/payments/data/models/ride_transaction_model.dart';

class RidePaymentRepository {
  final RidePaymentRemoteDatasource datasource;

  RidePaymentRepository(this.datasource);

  Future<void> markPaid(RideTransactionModel transaction) {
    return datasource.markPaid(transaction);
  }

  Stream<RideTransactionModel?> watchTransactionForRide(String rideId) {
    return datasource.watchTransactionForRide(rideId);
  }
}
