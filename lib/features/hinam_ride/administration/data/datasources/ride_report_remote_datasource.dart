import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/administration/data/models/ride_report_model.dart';

class RideReportRemoteDatasource {
  final FirebaseFirestore firestore;

  RideReportRemoteDatasource(this.firestore);

  Future<void> createReport(RideReportModel report) async {
    await firestore.collection('ride_reports').add(report.toMap());
  }

  // "Open" here means "not yet resolved" — it includes reports the admin has
  // already looked at (status == reviewed) so they remain visible until
  // resolved, not just brand-new ones.
  Stream<List<RideReportModel>> watchOpenReports() {
    return firestore
        .collection('ride_reports')
        .where('status', whereIn: ['open', 'reviewed'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideReportModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String adminUid,
    required RideReportStatus status,
  }) async {
    await firestore.collection('ride_reports').doc(reportId).update({
      'status': status.name,
      'reviewedBy': adminUid,
    });
  }
}
