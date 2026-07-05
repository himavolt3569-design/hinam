import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationTokenModel {
  final String uid;
  final String token;
  final String platform;
  final Timestamp updatedAt;

  const NotificationTokenModel({
    required this.uid,
    required this.token,
    required this.platform,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'token': token,
      'platform': platform,
      'updatedAt': updatedAt,
    };
  }

  factory NotificationTokenModel.fromMap(Map<String, dynamic> map) {
    return NotificationTokenModel(
      uid: map['uid'] ?? '',
      token: map['token'] ?? '',
      platform: map['platform'] ?? '',
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
