import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_manager.dart';
import '../../../core/localization/translation_sync_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/config/environment.dart';

class TranslationManagementPage extends StatefulWidget {
  const TranslationManagementPage({super.key});

  @override
  State<TranslationManagementPage> createState() =>
      _TranslationManagementPageState();
}

class _TranslationManagementPageState extends State<TranslationManagementPage> {
  bool _isSyncing = false;
  String? _lastSyncResult;
  List<String> _availableLanguages = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableLanguages();
  }

  Future<void> _loadAvailableLanguages() async {
    final languages = await TranslationSyncService.getAvailableLanguages();
    setState(() {
      _availableLanguages = languages;
    });
  }

  Future<void> _syncTranslations({bool force = false}) async {
    setState(() {
      _isSyncing = true;
      _lastSyncResult = null;
    });

    try {
      final success =
          force
              ? await TranslationSyncService.forceSync()
              : await TranslationSyncService.syncTranslations();

      setState(() {
        _lastSyncResult = success ? '✅ Sync thành công!' : '❌ Sync thất bại';
      });

      if (success) {
        await _loadAvailableLanguages();

        // Reload current language translations
        if (mounted) {
          // Trigger app to reload translations
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Translations updated! Restart app to see changes.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _lastSyncResult = '❌ Error: $e';
      });
      AppLogger.error('Sync error', e);
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _clearCache() async {
    try {
      await TranslationSyncService.clearCache();
      await _loadAvailableLanguages();

      setState(() {
        _lastSyncResult = '🗑️ Cache cleared';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Translation cache cleared'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Clear cache error', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final languageManager = Provider.of<LanguageManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Google Sheets Info
            _buildInfoCard(),

            const SizedBox(height: 20),

            // Sync Status
            _buildSyncStatus(),

            const SizedBox(height: 20),

            // Actions
            _buildActions(),

            const SizedBox(height: 20),

            // Available Languages
            _buildLanguagesList(),

            const SizedBox(height: 20),

            // Current Language Test
            _buildCurrentLanguageTest(t),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Google Sheets Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Sheet ID: ${Environment.googleSheetsId}'),
            Text('GID: ${Environment.googleSheetsGid}'),
            Text('Environment: ${Environment.environment}'),
            const SizedBox(height: 8),
            const Text(
              'Sheet format: key | en | vi | ja | ...',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔄 Sync Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_isSyncing)
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Syncing translations...'),
                ],
              )
            else if (_lastSyncResult != null)
              Text(_lastSyncResult!)
            else
              const Text('Ready to sync'),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : () => _syncTranslations(),
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSyncing
                            ? null
                            : () => _syncTranslations(force: true),
                    icon: const Icon(Icons.sync_alt),
                    label: const Text('Force Sync'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSyncing ? null : _clearCache,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Cache'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌍 Available Languages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_availableLanguages.isEmpty)
              const Text('No cached languages available')
            else
              Wrap(
                spacing: 8,
                children:
                    _availableLanguages.map((lang) {
                      return Chip(
                        label: Text(lang.toUpperCase()),
                        avatar: const Icon(Icons.language, size: 16),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLanguageTest(AppLocalizations t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧪 Current Language Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Language: ${t.currentLanguage}'),
            Text('Welcome: ${t.app('welcome')}'),
            Text('Login: ${t.auth('login')}'),
            Text('Settings: ${t.settings('title')}'),
          ],
        ),
      ),
    );
  }
}
