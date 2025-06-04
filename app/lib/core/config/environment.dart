import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_logger.dart';

class Environment {
  // API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'ZapChat';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  // Environment
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  // Authentication
  static String? get jwtSecret => dotenv.env['JWT_SECRET'];

  // External Services
  static String? get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'];
  static String? get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'];

  // Utility methods
  static void printConfig() {
    if (isDebugMode) {
      AppLogger.info('=== Environment Configuration ===');
      AppLogger.info('Environment: $environment');
      AppLogger.info('API Base URL: $apiBaseUrl');
      AppLogger.info('API Timeout: ${apiTimeout}ms');
      AppLogger.info('App Name: $appName');
      AppLogger.info('App Version: $appVersion');
      AppLogger.info('Debug Mode: $isDebugMode');
      AppLogger.info('=================================');
    }
  }

  // Validation
  static bool validateRequired() {
    final requiredVars = ['API_BASE_URL'];

    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        AppLogger.error('Required environment variable $varName is missing');
        return false;
      }
    }

    return true;
  }
}
