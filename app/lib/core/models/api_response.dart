import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final String? error;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  // Success response
  factory ApiResponse.success({T? data, String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message ?? 'Success',
      statusCode: statusCode ?? 200,
    );
  }

  // Error response
  factory ApiResponse.error({String? message, String? error, int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'An error occurred',
      error: error,
      statusCode: statusCode ?? 500,
    );
  }

  // Loading response
  factory ApiResponse.loading({String? message}) {
    return ApiResponse<T>(success: false, message: message ?? 'Loading...');
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, data: $data, statusCode: $statusCode, error: $error}';
  }
}
