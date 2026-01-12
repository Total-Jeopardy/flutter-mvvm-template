enum AppFlavor { dev, staging, prod }

class Env {
  // ---- Flavor ----
  static const String _flavorRaw = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static AppFlavor get flavor {
    switch (_flavorRaw.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppFlavor.prod;
      case 'staging':
      case 'stage':
        return AppFlavor.staging;
      default:
        return AppFlavor.dev;
    }
  }

  static bool get isDev => flavor == AppFlavor.dev;
  static bool get isStaging => flavor == AppFlavor.staging;
  static bool get isProd => flavor == AppFlavor.prod;

  // ---- API ----
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://example.com',
  );

  // ---- Logging / diagnostics (safe defaults) ----
  static bool get enableNetworkLogging =>
      bool.fromEnvironment('ENABLE_NET_LOGS', defaultValue: !isProd);

  static bool get enableNetworkBodyLogging =>
      bool.fromEnvironment('ENABLE_NET_BODY_LOGS', defaultValue: false);
}
