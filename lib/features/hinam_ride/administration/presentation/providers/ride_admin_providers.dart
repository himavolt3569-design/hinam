import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/hinam_ride/administration/data/repositories/ride_admin_repository.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_provider.dart';
import 'package:hinam/features/hinam_ride/passenger/presentation/providers/ride_passenger_provider.dart';
import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final rideAdminRepositoryProvider = Provider<RideAdminRepository>((ref) {
  return RideAdminRepository(ref.read(firestoreProvider));
});

final pendingRideVerificationsProvider =
    StreamProvider<List<VerificationRequestModel>>((ref) {
      return ref.watch(rideAdminRepositoryProvider).watchPendingVerifications();
    });

final verificationSubjectNameProvider =
    FutureProvider.family<String, VerificationRequestModel>((
      ref,
      request,
    ) async {
      if (request.subjectType == VerificationSubjectType.driver) {
        final driver = await ref
            .read(rideDriverRepositoryProvider)
            .getDriver(request.subjectId);
        return driver?.fullName ?? 'Unknown Driver';
      }

      final passenger = await ref
          .read(ridePassengerRepositoryProvider)
          .getPassenger(request.subjectId);
      return passenger?.fullName ?? 'Unknown Passenger';
    });

final verificationReviewControllerProvider =
    AsyncNotifierProvider<VerificationReviewController, void>(
      VerificationReviewController.new,
    );

class VerificationReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> approve(VerificationRequestModel request) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final adminUid = _currentAdminUid();
      await ref
          .read(rideAdminRepositoryProvider)
          .approveVerification(request, adminUid);
    });
  }

  Future<void> reject(VerificationRequestModel request, String reason) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final adminUid = _currentAdminUid();
      await ref
          .read(rideAdminRepositoryProvider)
          .rejectVerification(request, adminUid, reason);
    });
  }

  String _currentAdminUid() {
    final uid = ref.read(authControllerProvider.notifier).currentUser()?.uid;
    if (uid == null) throw StateError('No authenticated admin.');
    return uid;
  }
}
