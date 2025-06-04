import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

class AppErrorHandler {
  static bool _isInitialized = false;

  // Initialize global error handling
  static void initialize() {
    if (_isInitialized) return;

    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error(
        '🔥 Flutter Error: ${details.exception}',
        details.exception,
        details.stack,
      );

      // In development, also print to console
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // Handle async errors outside Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('🔥 Platform Error: $error', error, stack);
      return true; // Mark as handled
    };

    _isInitialized = true;
    AppLogger.info('✅ Global error handling initialized');
  }

  // Show user-friendly error dialog
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
            title: Text(title),
            content: Text(message),
            actions: [
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  child: const Text('Thử lại'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Log and handle network errors
  static void handleNetworkError(dynamic error, {String? context}) {
    final errorMessage =
        context != null ? '$context: $error' : 'Network error: $error';

    AppLogger.error('🌐 $errorMessage', error);
  }

  // Log and handle API errors
  static void handleApiError(dynamic error, {String? endpoint}) {
    final errorMessage =
        endpoint != null
            ? 'API error at $endpoint: $error'
            : 'API error: $error';

    AppLogger.error('🔌 $errorMessage', error);
  }
}
