import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../../routes/app_router.dart';
import '../themes/app_theme.dart';
import '../localization/app_localizations.dart';
import '../localization/language_manager.dart';
import 'app_initializer.dart';

class ZapChatApp extends StatelessWidget {
  const ZapChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppInitializer.languageManager,
      child: Consumer<LanguageManager>(
        builder: (context, languageManager, child) {
          return MaterialApp.router(
            title: 'ZapChat',
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,

            // Localization Configuration
            locale: languageManager.currentLocale,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,

            // Routing Configuration
            routerConfig: appRouter,

            // Builder for global app configuration
            builder: (context, child) {
              return MediaQuery(
                // Ensure text scales properly
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(
                      context,
                    ).textScaler.scale(1.0).clamp(0.8, 1.3),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
