import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDatasource(this.firebaseAuth);

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      verificationCompleted: (PhoneAuthCredential credential) async {
        await firebaseAuth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message);
      },

      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
