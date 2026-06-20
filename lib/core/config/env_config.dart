enum Environment { dev, prod }

class EnvConfig {
  static late Environment env;

  static bool get isDev => env == Environment.dev;
  static bool get isProd => env == Environment.prod;

  static String get apiBaseUrl {
    switch (env) {
      case Environment.dev:
        return "https://dev-api.local";
      case Environment.prod:
        return "https://api.production.com";
    }
  }
}