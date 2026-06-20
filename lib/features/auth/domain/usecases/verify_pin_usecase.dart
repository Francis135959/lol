import '../entities/user_credential.dart';
import '../repositories/auth_repository.dart';

class VerifyPinUsecase {
  final AuthRepository _repository;

  VerifyPinUsecase(this._repository);

  Future<bool> call(UserCredential credentials) {
    return _repository.verifyPin(credentials);
  }
}