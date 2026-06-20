import '../../domain/entities/user_credential.dart';
import '../../domain/usecases/verify_pin_usecase.dart';
import '../../../../core/state/base_viewmodel.dart';

import '../../data/datasources/pin_security_service.dart';

class PinViewModel extends BaseViewModel<bool> {
  final VerifyPinUsecase _verifyPinUsecase;
  final PinSecurityService _pinSecurityService;

  PinViewModel({
    required VerifyPinUsecase verifyPinUsecase,
    required PinSecurityService pinSecurityService,
  }) : _verifyPinUsecase = verifyPinUsecase, _pinSecurityService = pinSecurityService;

  Future<void> executeLogin(String pin) async {
    final cleanPin = pin.trim();

    if (cleanPin.isEmpty) {
      setError("Ingresa el PIN.");
      return;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(cleanPin)) {
      setError("El PIN debe tener exactamente 4 dígitos.");
      return;
    }

    setLoading();

    try {
      final credentials = UserCredential(pin: cleanPin);

      final lockoutUntil = await _pinSecurityService.getLockoutUntil();
      if (lockoutUntil != null && lockoutUntil.isAfter(DateTime.now())) {
        final diff = lockoutUntil.difference(DateTime.now());
        String timeStr = '';
        if (diff.inHours > 0) timeStr = '${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
        else if (diff.inMinutes > 0) timeStr = '${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
        else timeStr = '${diff.inSeconds} segundos';
        setError("Demasiados intentos fallidos. Intenta nuevamente en $timeStr.");
        return;
      }

      final success = await _verifyPinUsecase(credentials);

      if (success) {
        await _pinSecurityService.resetFailedAttempts();
        setSuccess(true);
      } else {
        await _pinSecurityService.recordFailedAttempt();
        final attempts = await _pinSecurityService.getFailedAttempts();
        final remaining = 10 - attempts;
        if (remaining <= 0) {
          setError("Demasiados intentos fallidos. Intenta nuevamente en 1 hora.");
        } else if (attempts >= 5) {
          final newLockout = await _pinSecurityService.getLockoutUntil();
          if (newLockout != null) {
            final diff = newLockout.difference(DateTime.now());
            String timeStr = '';
            if (diff.inHours > 0) timeStr = '${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
            else if (diff.inMinutes > 0) timeStr = '${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
            else timeStr = '${diff.inSeconds} segundos';
            setError("PIN incorrecto. Te quedan $remaining intentos.\nDemasiados intentos fallidos. Intenta nuevamente en $timeStr.");
          }
        } else {
          setError("PIN incorrecto. Te quedan $remaining intentos.");
        }
      }
    } catch (_) {
      setError("Ocurrió un error inesperado.");
    }
  }
}