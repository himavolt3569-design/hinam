import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDatasource(this.firebaseAuth);

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
  }) async {
    final completer = Completer<void>();

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      verificationCompleted: (PhoneAuthCredential credential) async {
        await firebaseAuth.signInWithCredential(credential);
        if (!completer.isCompleted) completer.complete();
      },

      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(e.message ?? 'Verification failed.'),
          );
        }
      },

      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
        if (!completer.isCompleted) completer.complete();
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return completer.future;
  }

  Future<User?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final result = await firebaseAuth.signInWithCredential(credential);

    return result.user;
  }

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
