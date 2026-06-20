import 'env_config.dart';

class AppConfig {
  static void init({required Environment environment}) {
    EnvConfig.env = environment;
  }
}