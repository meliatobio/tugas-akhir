import 'package:bengkel/constants/api_base.dart';
import 'package:dio/dio.dart';
import 'package:bengkel/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AuthUserService {
  final box = GetStorage();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiBase.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// ✅ Login User
  Future<UserModel?> login(String email, String password) async {
    final box = GetStorage();

    try {
      final response = await _dio.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Login response: ${response.data}');
        final user = UserModel.fromJson(response.data['user']);
        user.token = response.data['token'];

        // 🧠 Simpan token dan data user
        await box.write('token', user.token);
        await box.write('role', user.role);
        await box.write('user', user.toJson());
        await box.write('token', user.token);
        await box.write('userId', user.id); // simpan userId langsung

        debugPrint('✅ Token disimpan: ${user.token}');
        debugPrint('✅ Role disimpan: ${user.role}');

        return user;
      }
    } on DioException catch (e) {
      debugPrint(
        '❌ Login error: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    }

    return null;
  }

  /// ✅ Register User (Customer atau Store)
  Future<bool> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('auth/register', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Register success: ${response.data}');
        return true;
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      debugPrint(
        '❌ Register error: $statusCode - ${responseData ?? e.message}',
      );

      // ✅ Tangani error 400 maupun 422
      if ((statusCode == 400 || statusCode == 422) && responseData != null) {
        final errors = responseData['errors'];
        if (errors != null && errors['email'] != null) {
          final errorMessage =
              errors['email'][0]; // "The email has already been taken."
          throw errorMessage;
        }
      }

      // Jika bukan error yang dikenali
      throw 'Registrasi gagal. Silakan coba lagi.';
    }

    return false;
  }

  /// 📄 Get Profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get('profile');
      if (response.statusCode == 200) {
        debugPrint('📥 Profil berhasil: ${response.data}');
        return response.data['user'] ?? response.data['data'];
      }
    } on DioException catch (e) {
      debugPrint(
        '❌ Get profile error: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    }

    return null;
  }

  /// 📝 Update Profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('profile/update', data: data);

      debugPrint('📝 Update Profile Response: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint(
        '❌ Update profile error: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    }

    return false;
  }

  /// 🧠 Update User Profile from Local Storage (used in HomeOwnerScreen)
  Future<void> updateUserProfileFromStorage() async {
    final token = box.read('token');
    final userMap = box.read('user');

    if (token == null || userMap == null) {
      debugPrint('⚠️ Token atau user kosong di GetStorage');
      return;
    }

    // Set token ke header
    setToken(token);

    final data = {
      'name': userMap['name'],
      'email': userMap['email'],
      'phone_number': userMap['phone_number'],
    };

    debugPrint('📤 Mengirim update profil user dari storage: $data');

    await updateProfile(data);
  }

  /// 🚪 Logout
  Future<bool> logout() async {
    try {
      final response = await _dio.post('auth/logout');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      return false;
    }
  }

  /// 🔐 Change Password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // 🔍 Ambil data user dari storage
    final user = box.read('user');
    debugPrint('📦 Data user dari storage: $user');

    final email = user?['email'];
    debugPrint('📧 Email yang digunakan: $email');

    // ❗ Validasi apakah email tersedia
    if (email == null || email.isEmpty) {
      debugPrint('❌ Email tidak ditemukan di storage');
      return false;
    }

    try {
      final response = await _dio.post(
        'auth/reset-password',
        data: {
          'email': email, // ✅ Kirim email ke backend
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      debugPrint('✅ Change password response: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint(
        '❌ Change password error: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
      return false;
    } catch (e) {
      debugPrint('❌ Change password unexpected error: $e');
      return false;
    }
  }
}
