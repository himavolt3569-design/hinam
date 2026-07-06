import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart';

class RideVerificationRemoteDatasource {
  final FirebaseFirestore firestore;

  RideVerificationRemoteDatasource(this.firestore);

  Future<void> submitVerification(VerificationRequestModel request) async {
    await firestore.collection('ride_verifications').add(request.toMap());
  }

  Stream<VerificationRequestModel?> watchLatestForSubject(String subjectId) {
    return firestore
        .collection('ride_verifications')
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return VerificationRequestModel.fromMap(doc.id, doc.data());
        });
  }
}
