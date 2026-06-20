import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/settings_entity.dart';

class LocalSettingsDatasource {
  static const _keyIsDarkMode = 'settings_is_dark_mode';
  static const _keyIva = 'settings_iva';
  static const _keyMoneda = 'settings_moneda';
  static const _keyIsDebugMode = 'settings_is_debug_mode';
  static const _keyIsPinEnabled = 'settings_is_pin_enabled';
  static const _keyIsBiometricEnabled = 'settings_is_biometric_enabled';

  Future<SettingsEntity> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return SettingsEntity(
      isDarkMode: prefs.getBool(_keyIsDarkMode) ?? false,
      iva: prefs.getDouble(_keyIva) ?? 19.0,
      moneda: prefs.getString(_keyMoneda) ?? 'CLP',
      isDebugMode: prefs.getBool(_keyIsDebugMode) ?? false,
      isPinEnabled: prefs.getBool(_keyIsPinEnabled) ?? false,
      isBiometricEnabled: prefs.getBool(_keyIsBiometricEnabled) ?? false,
    );
  }

  Future<void> saveSettings(SettingsEntity settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_keyIsDarkMode, settings.isDarkMode);
    await prefs.setDouble(_keyIva, settings.iva);
    await prefs.setString(_keyMoneda, settings.moneda);
    await prefs.setBool(_keyIsDebugMode, settings.isDebugMode);
    await prefs.setBool(_keyIsPinEnabled, settings.isPinEnabled);
    await prefs.setBool(_keyIsBiometricEnabled, settings.isBiometricEnabled);
  }
}
