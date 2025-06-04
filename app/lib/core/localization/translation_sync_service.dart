import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import '../config/environment.dart';

class TranslationSyncService {
  // Google Sheets CSV export URL format
  // https://docs.google.com/spreadsheets/d/{SHEET_ID}/export?format=csv&gid={GID}
  static String get _sheetId => Environment.googleSheetsId;
  static String get _gid => Environment.googleSheetsGid;

  static const String _cacheKeyPrefix = 'translations_cache_';
  static const String _lastSyncKey = 'last_translation_sync';
  static const Duration _cacheDuration = Duration(hours: 6); // Cache 6 hours

  // Sync translations từ Google Sheets
  static Future<bool> syncTranslations() async {
    try {
      AppLogger.info('🔄 Starting translation sync from Google Sheets');

      // Check if need to sync (avoid too frequent requests)
      if (!await _shouldSync()) {
        AppLogger.debug('⏭️ Skipping sync - recent cache available');
        return true;
      }

      final csvUrl =
          'https://docs.google.com/spreadsheets/d/$_sheetId/export?format=csv&gid=$_gid';

      // Fetch CSV data
      final response = await http
          .get(Uri.parse(csvUrl), headers: {'Accept': 'text/csv'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch translations: ${response.statusCode}');
      }

      // Parse CSV
      final csvData = const CsvToListConverter().convert(response.body);

      if (csvData.isEmpty) {
        throw Exception('Empty CSV data received');
      }

      // Process and cache translations
      await _processCsvData(csvData);
      await _updateLastSyncTime();

      AppLogger.info('✅ Translation sync completed successfully');
      return true;
    } catch (e) {
      AppLogger.error('❌ Translation sync failed', e);
      return false;
    }
  }

  // Process CSV data and cache by language
  static Future<void> _processCsvData(List<List<dynamic>> csvData) async {
    if (csvData.length < 2) return;

    // First row is headers: [key, en, vi, ja, ...]
    final headers = csvData[0].cast<String>();
    final keyIndex = headers.indexOf('key');

    if (keyIndex == -1) {
      throw Exception('Key column not found in CSV');
    }

    // Initialize translation maps for each language
    final translations = <String, Map<String, dynamic>>{};

    // Get supported language codes from headers (skip 'key' column)
    final languageCodes = headers.where((h) => h != 'key').toList();

    for (final langCode in languageCodes) {
      translations[langCode] = <String, dynamic>{};
    }

    // Process each row (skip header)
    for (int i = 1; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.length <= keyIndex) continue;

      final key = row[keyIndex].toString().trim();
      if (key.isEmpty) continue;

      // Process each language column
      for (final langCode in languageCodes) {
        final langIndex = headers.indexOf(langCode);
        if (langIndex != -1 && langIndex < row.length) {
          final value = row[langIndex]?.toString().trim() ?? '';
          if (value.isNotEmpty) {
            _setNestedValue(translations[langCode]!, key, value);
          }
        }
      }
    }

    // Cache translations for each language
    for (final langCode in languageCodes) {
      await _cacheTranslations(langCode, translations[langCode]!);
    }
  }

  // Set nested value in map using dot notation (e.g., "app.welcome")
  static void _setNestedValue(
    Map<String, dynamic> map,
    String key,
    String value,
  ) {
    final parts = key.split('.');
    Map<String, dynamic> current = map;

    for (int i = 0; i < parts.length - 1; i++) {
      current[parts[i]] = current[parts[i]] ?? <String, dynamic>{};
      current = current[parts[i]] as Map<String, dynamic>;
    }

    current[parts.last] = value;
  }

  // Cache translations for a language
  static Future<void> _cacheTranslations(
    String languageCode,
    Map<String, dynamic> translations,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$languageCode';
      await prefs.setString(cacheKey, json.encode(translations));

      AppLogger.debug('💾 Cached translations for $languageCode');
    } catch (e) {
      AppLogger.error('Failed to cache translations for $languageCode', e);
    }
  }

  // Get cached translations for a language
  static Future<Map<String, dynamic>?> getCachedTranslations(
    String languageCode,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix$languageCode';
      final cachedJson = prefs.getString(cacheKey);

      if (cachedJson != null) {
        return json.decode(cachedJson) as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.error('Failed to get cached translations for $languageCode', e);
    }
    return null;
  }

  // Check if should sync (based on cache age)
  static Future<bool> _shouldSync() async {
    if (!Environment.isDebugMode) {
      // In production, check cache age
      try {
        final prefs = await SharedPreferences.getInstance();
        final lastSync = prefs.getInt(_lastSyncKey);

        if (lastSync != null) {
          final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSync);
          final timeSinceSync = DateTime.now().difference(lastSyncTime);

          return timeSinceSync > _cacheDuration;
        }
      } catch (e) {
        AppLogger.error('Error checking sync status', e);
      }
    }

    return true; // Always sync in debug mode or if no cache
  }

  // Update last sync time
  static Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      AppLogger.error('Failed to update last sync time', e);
    }
  }

  // Clear cache (for testing)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith(_cacheKeyPrefix),
      );

      for (final key in keys) {
        await prefs.remove(key);
      }

      await prefs.remove(_lastSyncKey);
      AppLogger.info('🗑️ Translation cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear translation cache', e);
    }
  }

  // Force sync (ignore cache)
  static Future<bool> forceSync() async {
    await clearCache();
    return await syncTranslations();
  }

  // Get available languages from cache
  static Future<List<String>> getAvailableLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith(_cacheKeyPrefix),
      );

      return keys.map((key) => key.replaceFirst(_cacheKeyPrefix, '')).toList();
    } catch (e) {
      AppLogger.error('Failed to get available languages', e);
      return ['en', 'vi']; // Default languages
    }
  }
}
