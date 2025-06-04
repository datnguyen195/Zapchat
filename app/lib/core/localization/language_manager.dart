import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('en', '');

  Locale get currentLocale => _currentLocale;

  // Get supported languages with display names
  List<LanguageOption> get supportedLanguages => [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      locale: const Locale('en', ''),
    ),
    LanguageOption(
      code: 'vi',
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
      locale: const Locale('vi', ''),
    ),
  ];

  // Initialize language from stored preference
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null) {
        final locale = Locale(savedLanguage, '');
        if (_isSupportedLocale(locale)) {
          _currentLocale = locale;
          notifyListeners();
        }
      } else {
        // Use system locale if supported, otherwise default to English
        final systemLocale = _getSystemLocale();
        _currentLocale =
            _isSupportedLocale(systemLocale)
                ? systemLocale
                : const Locale('en', '');
        await _saveLanguage(_currentLocale.languageCode);
        notifyListeners();
      }
    } catch (e) {
      // Default to English if error
      _currentLocale = const Locale('en', '');
    }
  }

  // Change language (giống i18n.changeLanguage())
  Future<void> changeLanguage(String languageCode) async {
    try {
      final newLocale = Locale(languageCode, '');

      if (_isSupportedLocale(newLocale) && newLocale != _currentLocale) {
        _currentLocale = newLocale;
        await _saveLanguage(languageCode);
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Change to specific locale
  Future<void> changeLocale(Locale locale) async {
    await changeLanguage(locale.languageCode);
  }

  // Get current language display name
  String getCurrentLanguageName() {
    return supportedLanguages
        .firstWhere(
          (lang) => lang.code == _currentLocale.languageCode,
          orElse: () => supportedLanguages.first,
        )
        .nativeName;
  }

  // Check if locale is supported
  bool _isSupportedLocale(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  // Get system locale
  Locale _getSystemLocale() {
    // This would ideally get from platform, for now return English
    return const Locale('en', '');
  }

  // Save language preference
  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  // Quick language toggle (for testing)
  Future<void> toggleLanguage() async {
    final nextLanguage = _currentLocale.languageCode == 'en' ? 'vi' : 'en';
    await changeLanguage(nextLanguage);
  }
}

// Language option model
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });
}
