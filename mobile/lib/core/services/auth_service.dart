import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_service.dart';
import '../models/user.dart';
import '../models/upload_response.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;
  final Dio _dio;

  AuthService(this._apiService, this._storageService, this._dio);

  // Register new user
  Future<User> register({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      final response = await _apiService.register({
        'email': email,
        'name': name,
        'password': password,
      });

      if (response.success && response.data != null) {
        final authResponse = response.data!;
        
        // Save token and user
        await _storageService.saveToken(authResponse.token);
        await _storageService.saveUser(authResponse.user);
        
        return authResponse.user;
      } else {
        throw Exception(response.error ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Login user
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login({
        'email': email,
        'password': password,
      });

      if (response.success && response.data != null) {
        final authResponse = response.data!;
        
        // Save token and user
        await _storageService.saveToken(authResponse.token);
        await _storageService.saveUser(authResponse.user);
        
        return authResponse.user;
      } else {
        throw Exception(response.error ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Logout user
  Future<void> logout() async {
    await _storageService.clearAll();
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      
      if (response.success && response.data != null) {
        await _storageService.saveUser(response.data!);
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      // If unauthorized, clear storage
      if (e.response?.statusCode == 401) {
        await logout();
      }
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storageService.getToken();
    return token != null;
  }

  // Get cached user
  Future<User?> getCachedUser() async {
    return await _storageService.getUser();
  }

  // Update profile
  Future<User> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
      if (currentPassword != null) body['currentPassword'] = currentPassword;
      if (newPassword != null) body['newPassword'] = newPassword;

      final response = await _apiService.updateProfile(body);

      if (response.success && response.data != null) {
        await _storageService.saveUser(response.data!);
        return response.data!;
      } else {
        throw Exception(response.error ?? 'Profile update failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload avatar image
  Future<String> uploadAvatar(XFile imageFile) async {
    try {
      // Create MultipartFile from XFile for cross-platform compatibility
      final bytes = await imageFile.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: imageFile.name,
      );
      
      // Create form data
      final formData = FormData.fromMap({
        'avatar': multipartFile,
      });
      
      // Use Dio directly for the upload
      final response = await _dio.post<Map<String, dynamic>>(
        '/upload/avatar',
        data: formData,
      );
      
      // Parse the response
      final apiResponse = ApiResponse<UploadResponse>.fromJson(
        response.data!,
        (json) => UploadResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!.avatarUrl;
      } else {
        throw Exception(apiResponse.error ?? 'Avatar upload failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update avatar (upload and update profile in one step)
  Future<User> updateAvatar(XFile imageFile) async {
    try {
      // First upload the image
      final avatarUrl = await uploadAvatar(imageFile);
      
      // Then update the profile with the new avatar URL
      return await updateProfile(avatarUrl: avatarUrl);
    } catch (e) {
      rethrow;
    }
  }

  // Error handling
  String _handleError(DioException error) {
    // Try to extract backend error message
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map) {
        if (data.containsKey('error') && data['error'] is String && data['error'].toString().isNotEmpty) {
          return data['error'].toString();
        }
        if (data.containsKey('message') && data['message'] is String && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
      }
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
