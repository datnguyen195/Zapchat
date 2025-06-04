import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_manager.dart';
import 'translation_management_page.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get translations (giống useTranslation trong RN)
    final t = AppLocalizations.of(context);
    final languageManager = Provider.of<LanguageManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings('title')), // settings.title
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Quick toggle button for demo
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () => languageManager.toggleLanguage(),
            tooltip: 'Toggle Language',
          ),
          // Translation Management button
          IconButton(
            icon: const Icon(Icons.cloud_sync),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TranslationManagementPage(),
                ),
              );
            },
            tooltip: 'Translation Management',
          ),
        ],
      ),
      body: ListView(
        children: [
          // Current Language Section
          _buildSection(
            context,
            title: t.settings('language'), // settings.language
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(t.settings('language')),
              subtitle: Text(languageManager.getCurrentLanguageName()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageBottomSheet(context),
            ),
          ),

          const Divider(),

          // Demo Usage Section
          _buildSection(
            context,
            title: 'Demo Translation Usage',
            child: Column(
              children: [
                // Basic translation
                _buildDemoTile(
                  context,
                  'Basic: t.app("welcome")',
                  t.app('welcome'), // app.welcome
                ),

                // Nested translation
                _buildDemoTile(
                  context,
                  'Nested: t.auth("login")',
                  t.auth('login'), // auth.login
                ),

                // Direct method
                _buildDemoTile(
                  context,
                  'Direct: t.t("user.profile")',
                  t.t('user.profile'), // user.profile
                ),

                // With parameters (if you add to JSON)
                _buildDemoTile(
                  context,
                  'Current Language',
                  'Language: ${t.currentLanguage}',
                ),

                // Error handling demo
                _buildDemoTile(
                  context,
                  'Error case: t.t("nonexistent.key")',
                  t.t('nonexistent.key'), // Returns key if not found
                ),
              ],
            ),
          ),

          const Divider(),

          // Action Buttons
          _buildSection(
            context,
            title: 'Actions',
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: Text(t.app('refresh')),
                  subtitle: const Text('Reload app to see changes'),
                  onTap: () {
                    // Demo reload app
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(t.app('refresh'))));
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.translate),
                  title: const Text('Toggle Language (Demo)'),
                  subtitle: Text(
                    'Current: ${languageManager.getCurrentLanguageName()}',
                  ),
                  onTap: () => languageManager.toggleLanguage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildDemoTile(BuildContext context, String demo, String result) {
    return ListTile(
      title: Text(
        demo,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
      subtitle: Text(
        'Result: "$result"',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final t = AppLocalizations.of(context);
    final languageManager = Provider.of<LanguageManager>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.settings('language'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...languageManager.supportedLanguages.map(
                (language) => ListTile(
                  leading: Text(
                    language.code.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: Text(language.nativeName),
                  subtitle: Text(language.name),
                  trailing:
                      languageManager.currentLocale.languageCode ==
                              language.code
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () {
                    languageManager.changeLanguage(language.code);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
