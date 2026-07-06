import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart';

class RideAdminRepository {
  final FirebaseFirestore firestore;

  RideAdminRepository(this.firestore);

  Stream<List<VerificationRequestModel>> watchPendingVerifications() {
    return firestore
        .collection('ride_verifications')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => VerificationRequestModel.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  Future<void> approveVerification(
    VerificationRequestModel request,
    String adminUid,
  ) async {
    final batch = firestore.batch();

    batch.update(firestore.collection('ride_verifications').doc(request.id), {
      'status': 'approved',
      'reviewedBy': adminUid,
      'reviewedAt': Timestamp.now(),
    });

    batch.update(
      firestore
          .collection(_profileCollectionFor(request.subjectType))
          .doc(request.subjectId),
      {'verificationStatus': 'approved'},
    );

    await batch.commit();
  }

  Future<void> rejectVerification(
    VerificationRequestModel request,
    String adminUid,
    String reason,
  ) async {
    final batch = firestore.batch();

    batch.update(firestore.collection('ride_verifications').doc(request.id), {
      'status': 'rejected',
      'reviewedBy': adminUid,
      'reviewedAt': Timestamp.now(),
      'rejectionReason': reason,
    });

    batch.update(
      firestore
          .collection(_profileCollectionFor(request.subjectType))
          .doc(request.subjectId),
      {'verificationStatus': 'rejected'},
    );

    await batch.commit();
  }

  String _profileCollectionFor(VerificationSubjectType subjectType) {
    switch (subjectType) {
      case VerificationSubjectType.driver:
        return 'ride_drivers';
      case VerificationSubjectType.passenger:
        return 'ride_passengers';
    }
  }
}
