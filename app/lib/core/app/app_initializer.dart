import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/environment.dart';
import '../utils/app_logger.dart';
import '../services/service_locator.dart';
import '../localization/language_manager.dart';
import '../localization/translation_sync_service.dart';
import 'app_error_handler.dart';

class AppInitializer {
  static bool _isInitialized = false;
  static LanguageManager? _languageManager;

  // Get language manager instance
  static LanguageManager get languageManager {
    if (_languageManager == null) {
      throw Exception(
        'AppInitializer not initialized. Call initialize() first.',
      );
    }
    return _languageManager!;
  }

  // Main initialization method
  static Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.warning('⚠️ AppInitializer already initialized');
      return;
    }

    try {
      // Ensure Flutter bindings
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Logger FIRST (basic mode before Environment loaded)
      AppLogger.initBasic();

      AppLogger.info('🚀 Starting ZapChat App Initialization...');

      // Initialize error handling first
      AppErrorHandler.initialize();

      // Load environment variables
      await _loadEnvironment();

      // Initialize core services
      await _initializeCoreServices();

      // Initialize feature services
      await _initializeFeatureServices();

      // Background tasks (non-blocking)
      _startBackgroundTasks();

      _isInitialized = true;
      AppLogger.info('✅ ZapChat App Initialization Completed');
    } catch (e) {
      AppLogger.fatal('❌ App Initialization Failed', e);
      rethrow;
    }
  }

  // Load and validate environment
  static Future<void> _loadEnvironment() async {
    AppLogger.debug('📄 Loading environment variables...');

    await dotenv.load(fileName: ".env");

    if (!Environment.validateRequired()) {
      throw Exception('Missing required environment variables');
    }

    // Print config in debug mode
    Environment.printConfig();
  }

  // Initialize core services (required for app to work)
  static Future<void> _initializeCoreServices() async {
    AppLogger.debug('🔧 Initializing core services...');

    // Re-init Logger with Environment configuration
    AppLogger.init();
    AppLogger.debug('🔄 Logger re-initialized with Environment config');

    // Setup Dependency Injection
    ServiceLocator.setup();

    AppLogger.info('✅ Core services initialized');
  }

  // Initialize feature services (can be async)
  static Future<void> _initializeFeatureServices() async {
    AppLogger.debug('📱 Initializing feature services...');

    // Initialize Language Manager with timeout
    AppLogger.debug('🌐 Starting Language Manager initialization...');
    _languageManager = LanguageManager();

    try {
      await _languageManager!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning(
            '⚠️ Language Manager initialization timeout, using defaults',
          );
        },
      );
      AppLogger.debug('✅ Language Manager initialized successfully');
    } catch (e) {
      AppLogger.error('❌ Language Manager initialization failed', e);
      // Continue with defaults
    }

    AppLogger.info('✅ Feature services initialized');
  }

  // Start background tasks (don't block app startup)
  static void _startBackgroundTasks() {
    AppLogger.debug('🔄 Starting background tasks...');

    // Auto-sync translations (non-blocking)
    _syncTranslationsInBackground();

    // Add other background tasks here
    // _preloadImages();
    // _syncUserData();
    // _checkAppUpdates();
  }

  // Background translation sync
  static void _syncTranslationsInBackground() {
    TranslationSyncService.syncTranslations()
        .timeout(const Duration(seconds: 30))
        .then((success) {
          if (success) {
            AppLogger.info('✅ Background translation sync completed');
          } else {
            AppLogger.warning(
              '⚠️ Background translation sync failed, using cached/bundled',
            );
          }
        })
        .catchError((error) {
          AppLogger.error('❌ Background translation sync error', error);
        });
  }

  // Cleanup method (for testing or app disposal)
  static Future<void> dispose() async {
    AppLogger.debug('🧹 Disposing App Initializer...');

    _languageManager = null;
    _isInitialized = false;

    AppLogger.info('✅ App Initializer disposed');
  }

  // Reset for testing
  static Future<void> reset() async {
    await dispose();
    await initialize();
  }

  // Check if app is initialized
  static bool get isInitialized => _isInitialized;
}
