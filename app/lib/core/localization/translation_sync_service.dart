import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../utils/app_logger.dart';
import '../config/environment.dart';

class TranslationSyncService {
  // Google Sheets API v4 URL format
  // https://sheets.googleapis.com/v4/spreadsheets/{SHEET_ID}/values/{SHEET_NAME}?key={API_KEY}
  static String get _sheetId => Environment.googleSheetsId;
  static String get _apiKey => Environment.googleSheetsApiKey;
  static String get _sheetName => Environment.googleSheetsName;

  static const Duration _syncCooldown = Duration(hours: 6); // Sync cooldown

  // Sync translations từ Google Sheets
  static Future<bool> syncTranslations() async {
    try {
      AppLogger.info('🔄 Starting translation sync from Google Sheets API');

      // Check if need to sync (avoid too frequent requests)
      if (!await _shouldSync()) {
        AppLogger.debug('⏭️ Skipping sync - recent cache available');
        return true;
      }

      final apiUrl =
          'https://sheets.googleapis.com/v4/spreadsheets/$_sheetId/values/$_sheetName?key=$_apiKey';

      // Fetch JSON data from Google Sheets API
      final response = await http
          .get(Uri.parse(apiUrl), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch translations: ${response.statusCode}');
      }

      // Parse JSON response
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final values = jsonData['values'] as List<dynamic>?;

      if (values == null || values.isEmpty) {
        throw Exception('Empty data received from Google Sheets');
      }

      // Process and cache translations
      await _processSheetData(values);
      await _updateLastSyncTime();

      AppLogger.info('✅ Translation sync completed successfully');
      return true;
    } catch (e) {
      AppLogger.error('❌ Translation sync failed', e);
      return false;
    }
  }

  // Process Google Sheets API data and cache by language
  static Future<void> _processSheetData(List<dynamic> sheetData) async {
    if (sheetData.length < 2) return;

    // First row is headers: [key, en, vi, ja, ...]
    final headers = (sheetData[0] as List<dynamic>).cast<String>();
    final keyIndex = headers.indexOf('key');

    if (keyIndex == -1) {
      throw Exception('Key column not found in sheet data');
    }

    // Initialize translation maps for each language
    final translations = <String, Map<String, dynamic>>{};

    // Get supported language codes from headers (skip 'key' column)
    final languageCodes = headers.where((h) => h != 'key').toList();

    for (final langCode in languageCodes) {
      translations[langCode] = <String, dynamic>{};
    }

    // Process each row (skip header)
    for (int i = 1; i < sheetData.length; i++) {
      final row = sheetData[i] as List<dynamic>;
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

    // Save translations to JSON files
    for (final langCode in languageCodes) {
      await _saveToJsonFile(langCode, translations[langCode]!);
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

  // Save translations to JSON file in translations folder
  static Future<void> _saveToJsonFile(
    String languageCode,
    Map<String, dynamic> translations,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final translationsDir = Directory('${directory.path}/translations');

      // Create translations directory if it doesn't exist
      if (!await translationsDir.exists()) {
        await translationsDir.create(recursive: true);
      }

      final file = File('${translationsDir.path}/$languageCode.json');
      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(translations);

      await file.writeAsString(jsonString);

      AppLogger.debug('📄 Saved translations to file: ${file.path}');
    } catch (e) {
      AppLogger.error(
        'Failed to save translations to file for $languageCode',
        e,
      );
    }
  }

  // Get saved translations for a language
  static Future<Map<String, dynamic>?> getCachedTranslations(
    String languageCode,
  ) async {
    try {
      // Load from saved JSON file
      return await _loadFromSavedFile(languageCode);
    } catch (e) {
      AppLogger.error('Failed to get saved translations for $languageCode', e);
    }
    return null;
  }

  // Load translations from saved JSON file
  static Future<Map<String, dynamic>?> _loadFromSavedFile(
    String languageCode,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/translations/$languageCode.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final translations = json.decode(jsonString) as Map<String, dynamic>;

        AppLogger.debug('📄 Loaded translations from file: ${file.path}');
        return translations;
      }
    } catch (e) {
      AppLogger.error(
        'Failed to load translations from file for $languageCode',
        e,
      );
    }
    return null;
  }

  // Check if should sync (based on file modification time)
  static Future<bool> _shouldSync() async {
    if (!Environment.isDebugMode) {
      // In production, check file age
      try {
        final directory = await getApplicationDocumentsDirectory();
        final lastSyncFile = File('${directory.path}/translations/.last_sync');

        if (await lastSyncFile.exists()) {
          final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(await lastSyncFile.readAsString()),
          );
          final timeSinceSync = DateTime.now().difference(lastSyncTime);

          return timeSinceSync > _syncCooldown;
        }
      } catch (e) {
        AppLogger.error('Error checking sync status', e);
      }
    }

    return true; // Always sync in debug mode or if no sync record
  }

  // Update last sync time
  static Future<void> _updateLastSyncTime() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final translationsDir = Directory('${directory.path}/translations');

      if (!await translationsDir.exists()) {
        await translationsDir.create(recursive: true);
      }

      final lastSyncFile = File('${translationsDir.path}/.last_sync');
      await lastSyncFile.writeAsString(
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      AppLogger.error('Failed to update last sync time', e);
    }
  }

  // Clear saved translations (for testing)
  static Future<void> clearCache() async {
    try {
      // Clear saved JSON files
      await _clearSavedFiles();

      AppLogger.info('🗑️ Translation files cleared');
    } catch (e) {
      AppLogger.error('Failed to clear translation files', e);
    }
  }

  // Clear saved translation files
  static Future<void> _clearSavedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final translationsDir = Directory('${directory.path}/translations');

      if (await translationsDir.exists()) {
        await translationsDir.delete(recursive: true);
        AppLogger.debug('📁 Deleted translations directory');
      }
    } catch (e) {
      AppLogger.error('Failed to clear saved translation files', e);
    }
  }

  // Force sync (ignore cache)
  static Future<bool> forceSync() async {
    await clearCache();
    return await syncTranslations();
  }

  // Get available languages from saved files
  static Future<List<String>> getAvailableLanguages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final translationsDir = Directory('${directory.path}/translations');

      if (await translationsDir.exists()) {
        final files = await translationsDir.list().toList();
        final languageCodes =
            files
                .whereType<File>()
                .where((file) => file.path.endsWith('.json'))
                .map(
                  (file) => file.path.split('/').last.replaceAll('.json', ''),
                )
                .toList();

        return languageCodes.isNotEmpty ? languageCodes : ['en', 'vi'];
      }

      return ['en', 'vi']; // Default languages
    } catch (e) {
      AppLogger.error('Failed to get available languages', e);
      return ['en', 'vi']; // Default languages
    }
  }
}
