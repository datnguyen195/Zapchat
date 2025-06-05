import 'package:flutter/material.dart';
import 'core/app/app_initializer.dart';
import 'core/app/zapchat_app.dart';
import 'core/app/splash_screen.dart';
import 'core/utils/app_logger.dart';

Future<void> main() async {
  // Show splash screen while initializing
  runApp(const SplashScreen(message: 'Khởi tạo ZapChat...'));

  try {
    // Initialize app with timeout to prevent indefinite hang
    await AppInitializer.initialize().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('App initialization timeout after 30 seconds');
      },
    );

    // Run the main app
    runApp(const ZapChatApp());
  } catch (e) {
    // Show error screen if initialization fails
    AppLogger.fatal('Failed to start ZapChat', e);
    runApp(_buildErrorApp(e.toString()));
  }
}

// Build error app if initialization fails
Widget _buildErrorApp(String error) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade600),
              const SizedBox(height: 24),
              const Text(
                'Khởi động ứng dụng thất bại',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Chi tiết lỗi:\n$error',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Restart app
                  main();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
