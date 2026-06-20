import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_settings_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final LocalSettingsDatasource localDatasource;

  SettingsRepositoryImpl({required this.localDatasource});

  @override
  Future<SettingsEntity> getSettings() {
    return localDatasource.getSettings();
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) {
    return localDatasource.saveSettings(settings);
  }
}
