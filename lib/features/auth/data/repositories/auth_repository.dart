import 'package:firebase_auth/firebase_auth.dart';
import 'package:hinam/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepository(this.datasource);

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
  }) async {
    await datasource.sendOtp(phoneNumber: phoneNumber, onCodeSent: onCodeSent);
  }

  Future<User?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    return datasource.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  User? currentUser() {
    return datasource.getCurrentUser();
  }

  Future<void> signOut() async {
    await datasource.signOut();
  }
}
