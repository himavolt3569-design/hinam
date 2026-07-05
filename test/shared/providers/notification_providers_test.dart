import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinam/features/auth/presentation/providers/auth_provider.dart';
import 'package:hinam/shared/models/notification_token_model.dart';
import 'package:hinam/shared/providers/notification_providers.dart';
import 'package:hinam/shared/repositories/notification_token_repository.dart';
import 'package:hinam/shared/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockNotificationTokenRepository extends Mock
    implements NotificationTokenRepository {}

class MockUser extends Mock implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      NotificationTokenModel(
        uid: 'fallback',
        token: 'fallback',
        platform: 'fallback',
        updatedAt: Timestamp.now(),
      ),
    );
  });

  late StreamController<User?> authStateController;
  late MockNotificationService notificationService;
  late MockNotificationTokenRepository tokenRepository;
  late ProviderContainer container;

  setUp(() {
    authStateController = StreamController<User?>.broadcast();
    notificationService = MockNotificationService();
    tokenRepository = MockNotificationTokenRepository();

    when(() => notificationService.requestPermission())
        .thenAnswer((_) async => true);
    when(() => notificationService.getToken())
        .thenAnswer((_) async => 'test-token');
    when(() => notificationService.platformName).thenReturn('android');
    when(() => notificationService.onTokenRefresh)
        .thenAnswer((_) => const Stream<String>.empty());
    when(() => tokenRepository.saveToken(any())).thenAnswer((_) async {});
    when(() => tokenRepository.deleteToken(any())).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        authStateChangesProvider.overrideWith(
          (ref) => authStateController.stream,
        ),
        notificationServiceProvider.overrideWithValue(notificationService),
        notificationTokenRepositoryProvider.overrideWithValue(
          tokenRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  tearDown(() {
    authStateController.close();
  });

  test('saves a token for the user once they log in', () async {
    container.listen(fcmTokenSyncProvider, (previous, next) {});

    final user = MockUser();
    when(() => user.uid).thenReturn('uid-1');

    authStateController.add(user);
    await Future<void>.delayed(Duration.zero);

    final captured =
        verify(() => tokenRepository.saveToken(captureAny())).captured;
    final saved = captured.single as NotificationTokenModel;

    expect(saved.uid, 'uid-1');
    expect(saved.token, 'test-token');
    expect(saved.platform, 'android');
  });

  test('deletes the token once the user logs out', () async {
    container.listen(fcmTokenSyncProvider, (previous, next) {});

    final user = MockUser();
    when(() => user.uid).thenReturn('uid-1');

    authStateController.add(user);
    await Future<void>.delayed(Duration.zero);

    authStateController.add(null);
    await Future<void>.delayed(Duration.zero);

    verify(() => tokenRepository.deleteToken('uid-1')).called(1);
  });

  test('does not save a token when permission is denied', () async {
    when(() => notificationService.requestPermission())
        .thenAnswer((_) async => false);

    container.listen(fcmTokenSyncProvider, (previous, next) {});

    final user = MockUser();
    when(() => user.uid).thenReturn('uid-1');

    authStateController.add(user);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => tokenRepository.saveToken(any()));
  });
}
