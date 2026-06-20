import '../../../../core/state/base_viewmodel.dart';
import '../../domain/entities/user_credential.dart';
import '../../domain/usecases/recover_pin_usecase.dart';

class RecoverPinViewModel extends BaseViewModel<bool> {
  final RecoverPinUsecase _usecase;

  RecoverPinViewModel({
    required RecoverPinUsecase recoverPinUsecase,
  }) : _usecase = recoverPinUsecase;

  Future<void> verifyAnswers({
    required String a1,
    required String a2,
    required String a3,
  }) async {
    if (a1.trim().isEmpty || a2.trim().isEmpty || a3.trim().isEmpty) {
      setError("Completa todas las respuestas.");
      return;
    }

    setLoading();

    final credentials = UserCredential(
      pin: "",
      answer1: a1,
      answer2: a2,
      answer3: a3,
    );

    final ok = await _usecase(credentials);

    if (ok) {
      setSuccess(true);
    } else {
      setError("Respuestas incorrectas.");
    }
  }
}