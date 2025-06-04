import 'package:dio/dio.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Lấy thông tin user theo ID
  Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final response = await _apiClient.get('/users/$userId');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Lấy danh sách users
  Future<List<dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        '/users',
        queryParameters: queryParams,
      );

      return response.data['data'] as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Tạo user mới
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post('/users', data: userData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật thông tin user
  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _apiClient.put('/users/$userId', data: userData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Xóa user
  Future<bool> deleteUser(int userId) async {
    try {
      await _apiClient.delete('/users/$userId');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post('/auth/register', data: userData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Upload avatar
  Future<Map<String, dynamic>> uploadAvatar(
    int userId,
    String imagePath,
  ) async {
    try {
      final response = await _apiClient.uploadFile(
        '/users/$userId/avatar',
        imagePath,
        fileName: 'avatar.jpg',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      await _apiClient.post('/auth/logout');
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
