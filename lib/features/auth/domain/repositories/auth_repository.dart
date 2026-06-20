import '../entities/user_credential.dart';

abstract class AuthRepository {
  Future<bool> verifyPin(UserCredential credentials);

  Future<bool> recoverPin(UserCredential credentials);
}