import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/hinam_ride/administration/data/datasources/ride_report_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/administration/data/models/ride_report_model.dart';
import 'package:hinam/features/hinam_ride/administration/data/repositories/ride_report_repository.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_provider.dart';
import 'package:hinam/features/hinam_ride/passenger/presentation/providers/ride_passenger_provider.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';

final rideReportDatasourceProvider = Provider<RideReportRemoteDatasource>(
  (ref) => RideReportRemoteDatasource(ref.read(firestoreProvider)),
);

final rideReportRepositoryProvider = Provider<RideReportRepository>(
  (ref) => RideReportRepository(ref.read(rideReportDatasourceProvider)),
);

final openReportsProvider = StreamProvider<List<RideReportModel>>((ref) {
  return ref.watch(rideReportRepositoryProvider).watchOpenReports();
});

/// Resolves a uid to a display name for the admin review card — a reported
/// party may be either a ride driver or a ride passenger, so this checks
/// both existing profile repositories rather than duplicating either one.
final reportedUserNameProvider = FutureProvider.family<String, String>((
  ref,
  uid,
) async {
  final driver = await ref.read(rideDriverRepositoryProvider).getDriver(uid);
  if (driver != null) return driver.fullName;

  final passenger = await ref
      .read(ridePassengerRepositoryProvider)
      .getPassenger(uid);
  if (passenger != null) return passenger.fullName;

  return 'Unknown User';
});

final reportFilingControllerProvider =
    AsyncNotifierProvider<ReportFilingController, void>(
      ReportFilingController.new,
    );

class ReportFilingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> fileReport({
    required String rideId,
    required String reportedUserId,
    required String reason,
    required String details,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final reportedBy = ref
          .read(authControllerProvider.notifier)
          .currentUser()
          ?.uid;
      if (reportedBy == null) {
        throw StateError('You must be signed in to file a report.');
      }

      final report = RideReportModel(
        id: '',
        rideId: rideId,
        reportedBy: reportedBy,
        reportedUserId: reportedUserId,
        reason: reason,
        details: details,
        status: RideReportStatus.open,
        createdAt: Timestamp.now(),
      );

      await ref.read(rideReportRepositoryProvider).createReport(report);
    });
  }
}

final reportReviewControllerProvider =
    AsyncNotifierProvider<ReportReviewController, void>(
      ReportReviewController.new,
    );

class ReportReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markReviewed(String reportId) async {
    await _updateStatus(reportId, RideReportStatus.reviewed);
  }

  Future<void> resolve(String reportId) async {
    await _updateStatus(reportId, RideReportStatus.resolved);
  }

  Future<void> _updateStatus(String reportId, RideReportStatus status) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final adminUid = ref
          .read(authControllerProvider.notifier)
          .currentUser()
          ?.uid;
      if (adminUid == null) {
        throw StateError('No authenticated admin.');
      }

      await ref
          .read(rideReportRepositoryProvider)
          .updateReportStatus(
            reportId: reportId,
            adminUid: adminUid,
            status: status,
          );
    });
  }
}
