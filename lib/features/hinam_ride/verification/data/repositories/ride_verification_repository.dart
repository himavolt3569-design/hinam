import 'package:hinam/features/hinam_ride/verification/data/datasources/ride_verification_remote_datasource.dart';
import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart';

class RideVerificationRepository {
  final RideVerificationRemoteDatasource datasource;

  RideVerificationRepository(this.datasource);

  Future<void> submitVerification(VerificationRequestModel request) {
    return datasource.submitVerification(request);
  }

  Stream<VerificationRequestModel?> watchLatestForSubject(String subjectId) {
    return datasource.watchLatestForSubject(subjectId);
  }
}
