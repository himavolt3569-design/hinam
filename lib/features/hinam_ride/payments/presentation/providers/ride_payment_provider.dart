import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/payments/data/datasources/ride_payment_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/payments/data/models/ride_transaction_model.dart';
import 'package:hinam/features/hinam_ride/payments/data/repositories/ride_payment_repository.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final ridePaymentDatasourceProvider = Provider<RidePaymentRemoteDatasource>(
  (ref) => RidePaymentRemoteDatasource(ref.read(firestoreProvider)),
);

final ridePaymentRepositoryProvider = Provider<RidePaymentRepository>(
  (ref) => RidePaymentRepository(ref.read(ridePaymentDatasourceProvider)),
);

final rideTransactionProvider =
    StreamProvider.family<RideTransactionModel?, String>((ref, rideId) {
      return ref
          .watch(ridePaymentRepositoryProvider)
          .watchTransactionForRide(rideId);
    });

final ridePaymentControllerProvider =
    AsyncNotifierProvider<RidePaymentController, void>(
      RidePaymentController.new,
    );

class RidePaymentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markPaid({
    required String rideId,
    required String payerId,
    required String payeeId,
    required double amount,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final transaction = RideTransactionModel(
        id: rideId,
        rideId: rideId,
        payerId: payerId,
        payeeId: payeeId,
        amount: amount,
        method: PaymentMethod.cash,
        status: RideTransactionStatus.completed,
        createdAt: Timestamp.now(),
      );

      await ref.read(ridePaymentRepositoryProvider).markPaid(transaction);
    });
  }
}
