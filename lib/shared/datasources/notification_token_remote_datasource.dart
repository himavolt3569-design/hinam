import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hinam/shared/models/notification_token_model.dart';

class NotificationTokenRemoteDatasource {
  final FirebaseFirestore firestore;

  NotificationTokenRemoteDatasource(this.firestore);

  Future<void> saveToken(NotificationTokenModel token) async {
    await firestore
        .collection('fcm_tokens')
        .doc(token.uid)
        .set(token.toMap());
  }

  Future<void> deleteToken(String uid) async {
    await firestore.collection('fcm_tokens').doc(uid).delete();
  }
}
