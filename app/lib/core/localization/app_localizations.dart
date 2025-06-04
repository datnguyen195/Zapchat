import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'translation_sync_service.dart';
import '../utils/app_logger.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  // Helper để get current instance từ context (giống useTranslation)
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Support languages
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('vi', ''), // Vietnamese
  ];

  // Load translation - Priority: Cache > Bundle > Fallback
  Future<bool> load() async {
    try {
      // Try to load from cache first (Google Sheets data)
      final cachedTranslations =
          await TranslationSyncService.getCachedTranslations(
            locale.languageCode,
          );

      if (cachedTranslations != null && cachedTranslations.isNotEmpty) {
        _localizedStrings = cachedTranslations;
        AppLogger.debug(
          '📄 Loaded translations from cache for ${locale.languageCode}',
        );
        return true;
      }

      // Fallback to bundled JSON files
      AppLogger.warning(
        '📦 Falling back to bundled translations for ${locale.languageCode}',
      );
      return await _loadFromBundle();
    } catch (e) {
      AppLogger.error(
        '❌ Failed to load translations for ${locale.languageCode}',
        e,
      );

      // Final fallback to English bundle
      if (locale.languageCode != 'en') {
        return await _loadFromBundle('en');
      }

      // If all fails, set empty map to prevent crashes
      _localizedStrings = {};
      return false;
    }
  }

  // Load from bundled JSON files (fallback)
  Future<bool> _loadFromBundle([String? languageCode]) async {
    try {
      final lang = languageCode ?? locale.languageCode;
      final jsonString = await rootBundle.loadString(
        'lib/core/localization/translations/$lang.json',
      );
      _localizedStrings = json.decode(jsonString) as Map<String, dynamic>;
      return true;
    } catch (e) {
      if (languageCode == null && locale.languageCode != 'en') {
        // Try English as final fallback
        return await _loadFromBundle('en');
      }
      return false;
    }
  }

  // Main translation method - support nested keys như "auth.login"
  String t(String key, {Map<String, dynamic>? params}) {
    try {
      List<String> keys = key.split('.');
      dynamic value = _localizedStrings;

      // Navigate through nested structure
      for (String k in keys) {
        if (value is Map<String, dynamic> && value.containsKey(k)) {
          value = value[k];
        } else {
          return key; // Return key if not found
        }
      }

      String result = value.toString();

      // Replace parameters {{param}}
      if (params != null) {
        params.forEach((paramKey, paramValue) {
          result = result.replaceAll('{{$paramKey}}', paramValue.toString());
        });
      }

      return result;
    } catch (e) {
      return key; // Return key if error
    }
  }

  // Pluralization support
  String plural(String key, int count, {Map<String, dynamic>? params}) {
    String pluralKey = count == 1 ? '${key}_one' : '${key}_other';
    Map<String, dynamic> allParams = {'count': count};
    if (params != null) allParams.addAll(params);

    String result = t(pluralKey, params: allParams);
    if (result == pluralKey) {
      // Fallback to singular form if plural not found
      return t(key, params: allParams);
    }
    return result;
  }

  // Get current language code
  String get currentLanguage => locale.languageCode;

  // Check if language is RTL
  bool get isRTL => locale.languageCode == 'ar' || locale.languageCode == 'fa';

  // Convenience getters cho common sections
  _TranslationSection get app => _TranslationSection(this, 'app');
  _TranslationSection get auth => _TranslationSection(this, 'auth');
  _TranslationSection get user => _TranslationSection(this, 'user');
  _TranslationSection get weather => _TranslationSection(this, 'weather');
  _TranslationSection get chat => _TranslationSection(this, 'chat');
  _TranslationSection get settings => _TranslationSection(this, 'settings');
  _TranslationSection get errors => _TranslationSection(this, 'errors');
}

// Helper class để access nested translations
class _TranslationSection {
  final AppLocalizations _localizations;
  final String _section;

  _TranslationSection(this._localizations, this._section);

  String call(String key, {Map<String, dynamic>? params}) {
    return _localizations.t('$_section.$key', params: params);
  }

  String plural(String key, int count, {Map<String, dynamic>? params}) {
    return _localizations.plural('$_section.$key', count, params: params);
  }
}

// Delegate class for Flutter localization
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
