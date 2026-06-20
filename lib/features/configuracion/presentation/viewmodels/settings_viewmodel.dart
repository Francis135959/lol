import '../../../../core/state/base_viewmodel.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../auth/data/datasources/pin_security_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsViewModel extends BaseViewModel<SettingsEntity> {
  final SettingsRepository repository;
  final PinSecurityService pinSecurityService;

  SettingsViewModel({
    required this.repository,
    required this.pinSecurityService,
  });

  Future<void> loadSettings() async {
    setLoading();
    try {
      final settings = await repository.getSettings();
      setSuccess(settings);
    } catch (e) {
      setError("Error al cargar configuración: \${e.toString()}");
    }
  }

  Future<void> saveAllSettings({
    required bool isDark,
    required double iva,
    required String moneda,
    required bool isDebug,
    required bool isPinEnabled,
    required bool isBiometricEnabled,
  }) async {
    if (state.data == null) return;

    final updated = state.data!.copyWith(
      isDarkMode: isDark,
      iva: iva,
      moneda: moneda,
      isDebugMode: isDebug,
      isPinEnabled: isPinEnabled,
      isBiometricEnabled: isBiometricEnabled,
    );

    await repository.saveSettings(updated);

    if (!isPinEnabled) {
      await pinSecurityService.deletePinSetup();
    }

    setSuccess(updated);
  }

  Future<String> getCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalSize = 0;
      if (tempDir.existsSync()) {
        for (var entity in tempDir.listSync(recursive: true, followLinks: false)) {
          if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
            totalSize += entity.lengthSync();
          }
        }
      }

      if (totalSize == 0) return '0.0 KB';

      final mb = totalSize / (1024 * 1024);
      if (mb < 1) {
        return '${(totalSize / 1024).toStringAsFixed(1)} KB';
      }
      return '${mb.toStringAsFixed(2)} MB';
    } catch (e) {
      return '0.0 KB';
    }
  }

  Future<void> clearCache() async {
    setLoading();
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        for (var entity in tempDir.listSync(recursive: true, followLinks: false)) {
          if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
            try {
              entity.deleteSync();
            } catch (_) {
            }
          }
        }
      }
      if (state.data != null) {
        setSuccess(state.data!);
      }
    } catch (e) {
      setError("Error al limpiar la caché");
    }
  }

  Future<void> setupPin({
    required String pin,
    required String a1,
    required String a2,
    required String a3,
  }) async {
    try {
      await pinSecurityService.savePinSetup(
        pin: pin,
        answer1: a1,
        answer2: a2,
        answer3: a3,
      );
    } catch (e) {
      print("ERROR SETUP PIN: $e");
      setError("Error al guardar el PIN de seguridad: $e");
    }
  }
}