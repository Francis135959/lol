import '../entities/user_credential.dart';
import '../repositories/auth_repository.dart';

class RecoverPinUsecase {
  final AuthRepository _repository;

  RecoverPinUsecase(this._repository);

  Future<bool> call(UserCredential credentials) {
    return _repository.recoverPin(credentials);
  }
}
