import '../../domain/entities/user_credential.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/pin_security_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final PinSecurityService securityService;

  AuthRepositoryImpl({required this.securityService});

  @override
  Future<bool> verifyPin(UserCredential credentials) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Animación de carga
    return securityService.verifyPin(credentials.pin);
  }

  @override
  Future<bool> recoverPin(UserCredential credentials) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return securityService.verifyAnswers(
      answer1: credentials.answer1,
      answer2: credentials.answer2,
      answer3: credentials.answer3,
    );
  }
}
