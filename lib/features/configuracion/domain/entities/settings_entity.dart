class SettingsEntity {
  final bool isDarkMode;
  final double iva;
  final String moneda;
  final bool isDebugMode;
  final bool isPinEnabled;
  final bool isBiometricEnabled;

  SettingsEntity({
    this.isDarkMode = false,
    this.iva = 19.0,
    this.moneda = 'CLP',
    this.isDebugMode = false,
    this.isPinEnabled = false,
    this.isBiometricEnabled = false,
  });

  SettingsEntity copyWith({
    bool? isDarkMode,
    double? iva,
    String? moneda,
    bool? isDebugMode,
    bool? isPinEnabled,
    bool? isBiometricEnabled,
  }) {
    return SettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      iva: iva ?? this.iva,
      moneda: moneda ?? this.moneda,
      isDebugMode: isDebugMode ?? this.isDebugMode,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}
