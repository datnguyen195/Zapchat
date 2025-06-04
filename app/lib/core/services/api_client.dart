import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../utils/app_logger.dart';

class ApiClient {
  // Sử dụng Environment class
  static String get baseUrl => Environment.apiBaseUrl;
  static int get connectTimeout => Environment.apiTimeout;
  static int get receiveTimeout => Environment.apiTimeout;
  static bool get isDebugMode => Environment.isDebugMode;

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: connectTimeout),
        receiveTimeout: Duration(milliseconds: receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thêm custom logging interceptor
    if (isDebugMode) {
      _dio.interceptors.add(_createLoggingInterceptor());
    }

    // Thêm interceptor để handle authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Thêm token authentication nếu có
          // final token = getStoredToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle error globally
          if (error.response?.statusCode == 401) {
            // Token hết hạn, redirect to login
            // clearToken();
            // navigateToLogin();
          }
          handler.next(error);
        },
      ),
    );
  }

  // Tạo custom logging interceptor
  InterceptorsWrapper _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final stopwatch = Stopwatch()..start();
        options.extra['startTime'] = stopwatch;

        AppLogger.api(
          options.method,
          '${options.baseUrl}${options.path}',
          headers: options.headers,
          body: options.data,
        );

        handler.next(options);
      },
      onResponse: (response, handler) {
        final stopwatch =
            response.requestOptions.extra['startTime'] as Stopwatch?;
        stopwatch?.stop();

        AppLogger.api(
          response.requestOptions.method,
          '${response.requestOptions.baseUrl}${response.requestOptions.path}',
          statusCode: response.statusCode,
          response: response.data,
          duration: stopwatch?.elapsed,
        );

        handler.next(response);
      },
      onError: (error, handler) {
        final stopwatch = error.requestOptions.extra['startTime'] as Stopwatch?;
        stopwatch?.stop();

        AppLogger.api(
          error.requestOptions.method,
          '${error.requestOptions.baseUrl}${error.requestOptions.path}',
          statusCode: error.response?.statusCode,
          error: error.message,
          duration: stopwatch?.elapsed,
        );

        handler.next(error);
      },
    );
  }

  Dio get dio => _dio;

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...?data,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException('Kết nối timeout');
        case DioExceptionType.badResponse:
          return HttpException(
            'HTTP Error: ${error.response?.statusCode}',
            error.response?.statusCode ?? 0,
          );
        case DioExceptionType.cancel:
          return CancelException('Request đã bị hủy');
        case DioExceptionType.connectionError:
          return NetworkException('Lỗi kết nối mạng');
        default:
          return UnknownException('Lỗi không xác định');
      }
    }
    return UnknownException(error.toString());
  }
}

// Custom exceptions
class HttpException implements Exception {
  final String message;
  final int statusCode;
  HttpException(this.message, this.statusCode);
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class CancelException implements Exception {
  final String message;
  CancelException(this.message);
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);
}
