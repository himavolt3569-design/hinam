import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/auth/presentation/providers/auth_provider.dart';
import 'package:hinam/shared/datasources/notification_token_remote_datasource.dart';
import 'package:hinam/shared/models/notification_token_model.dart';
import 'package:hinam/shared/providers/firebase_providers.dart';
import 'package:hinam/shared/repositories/notification_token_repository.dart';
import 'package:hinam/shared/services/notification_service.dart';

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(firebaseMessagingProvider));
});

final notificationTokenDatasourceProvider =
    Provider<NotificationTokenRemoteDatasource>((ref) {
      return NotificationTokenRemoteDatasource(ref.read(firestoreProvider));
    });

final notificationTokenRepositoryProvider =
    Provider<NotificationTokenRepository>((ref) {
      return NotificationTokenRepository(
        ref.read(notificationTokenDatasourceProvider),
      );
    });

final fcmTokenSyncProvider = Provider<void>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final tokenRepository = ref.read(notificationTokenRepositoryProvider);

  Future<void> saveTokenForUser(User user) async {
    final granted = await notificationService.requestPermission();
    if (!granted) return;

    final token = await notificationService.getToken();
    if (token == null) return;

    await tokenRepository.saveToken(
      NotificationTokenModel(
        uid: user.uid,
        token: token,
        platform: notificationService.platformName,
        updatedAt: Timestamp.now(),
      ),
    );
  }

  ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
    final previousUser = previous?.value;
    final nextUser = next.value;

    if (nextUser != null) {
      saveTokenForUser(nextUser);
    } else if (previousUser != null) {
      tokenRepository.deleteToken(previousUser.uid);
    }
  });

  final refreshSubscription = notificationService.onTokenRefresh.listen((_) {
    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser != null) {
      saveTokenForUser(currentUser);
    }
  });

  ref.onDispose(refreshSubscription.cancel);
});
