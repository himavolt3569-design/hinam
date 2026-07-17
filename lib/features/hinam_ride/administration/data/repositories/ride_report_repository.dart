import 'package:hinam/features/hinam_ride/administration/data/datasources/ride_report_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/administration/data/models/ride_report_model.dart';

class RideReportRepository {
  final RideReportRemoteDatasource datasource;

  RideReportRepository(this.datasource);

  Future<void> createReport(RideReportModel report) {
    return datasource.createReport(report);
  }

  Stream<List<RideReportModel>> watchOpenReports() {
    return datasource.watchOpenReports();
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String adminUid,
    required RideReportStatus status,
  }) {
    return datasource.updateReportStatus(
      reportId: reportId,
      adminUid: adminUid,
      status: status,
    );
  }
}
