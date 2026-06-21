import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/auth/data/repositories/auth_repository.dart';
import 'auth_provider.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository repository;

  @override
  Future<void> build() async {
    repository = ref.read(authRepositoryProvider);
  }

  Future<void> sendOtp({required String phoneNumber, required void Function(String verificationId) onCodeSent}) async {
    state = const AsyncValue.loading();

    try {
      await repository.sendOtp(phoneNumber: phoneNumber, onCodeSent: onCodeSent);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<User?> verifyOtp({required String verificationId, required String smsCode}) async {
    state = const AsyncValue.loading();

    try {
      final user = await repository.verifyOtp(verificationId: verificationId, smsCode: smsCode);
      state = const AsyncValue.data(null);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  User? currentUser() {
    return repository.currentUser();
  }

  Future<void> signOut() async {
    return repository.signOut();
  }
}
