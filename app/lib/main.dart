import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_router.dart';
import 'core/themes/app_theme.dart';
import 'core/services/service_locator.dart';
import 'core/config/environment.dart';
import 'core/utils/app_logger.dart';

Future<void> main() async {
  // Đảm bảo Flutter bindings được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Khởi tạo Logger
  AppLogger.init();

  // Validate required environment variables
  if (!Environment.validateRequired()) {
    AppLogger.fatal('Missing required environment variables');
    throw Exception('Missing required environment variables');
  }

  // Print config in debug mode
  Environment.printConfig();

  // Khởi tạo ServiceLocator sau khi load env
  ServiceLocator.setup();

  AppLogger.info('🚀 ZapChat App Started');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZapChat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
