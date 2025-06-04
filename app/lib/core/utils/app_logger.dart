import 'package:logger/logger.dart';
import '../config/environment.dart';

class AppLogger {
  static late Logger _logger;

  // Khởi tạo logger
  static void init() {
    _logger = Logger(
      level: _getLogLevel(),
      printer: _getPrinter(),
      output: _getOutput(),
    );
  }

  // Lấy log level dựa trên environment
  static Level _getLogLevel() {
    if (Environment.isProduction) {
      return Level.warning; // Chỉ log warning và error trong production
    } else if (Environment.isStaging) {
      return Level.info; // Log info, warning, error trong staging
    } else {
      return Level.debug; // Log tất cả trong development
    }
  }

  // Cấu hình printer dựa trên environment
  static LogPrinter _getPrinter() {
    if (Environment.isProduction) {
      // Production: Simple printer, ít thông tin
      return SimplePrinter(colors: false);
    } else {
      // Development/Staging: Pretty printer với colors
      return PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      );
    }
  }

  // Cấu hình output
  static LogOutput _getOutput() {
    if (Environment.isProduction) {
      // Production: Có thể gửi logs đến server hoặc file
      return ConsoleOutput();
    } else {
      // Development: Console output
      return ConsoleOutput();
    }
  }

  // Debug logs
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // Info logs
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // Warning logs
  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // Error logs
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // Fatal logs
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // API logs (riêng cho API calls)
  static void api(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
    int? statusCode,
    dynamic response,
    Duration? duration,
    dynamic error,
  }) {
    if (!Environment.isDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln('🌐 API Call: $method $url');

    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('📋 Headers: $headers');
    }

    if (body != null) {
      buffer.writeln('📤 Request: $body');
    }

    if (statusCode != null) {
      buffer.writeln('📊 Status: $statusCode');
    }

    if (response != null) {
      buffer.writeln('📥 Response: $response');
    }

    if (duration != null) {
      buffer.writeln('⏱️  Duration: ${duration.inMilliseconds}ms');
    }

    if (error != null) {
      _logger.e(buffer.toString(), error: error);
    } else {
      _logger.d(buffer.toString());
    }
  }

  // Performance logs
  static void performance(
    String operation,
    Duration duration, [
    Map<String, dynamic>? metadata,
  ]) {
    if (!Environment.isDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln('⚡ Performance: $operation');
    buffer.writeln('⏱️  Duration: ${duration.inMilliseconds}ms');

    if (metadata != null && metadata.isNotEmpty) {
      buffer.writeln('📊 Metadata: $metadata');
    }

    if (duration.inMilliseconds > 1000) {
      _logger.w(buffer.toString());
    } else {
      _logger.d(buffer.toString());
    }
  }
}
