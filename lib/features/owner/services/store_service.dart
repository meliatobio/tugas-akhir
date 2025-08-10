import 'dart:io';
import 'package:dio/dio.dart';

import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:get_storage/get_storage.dart';

final Dio _dio = Dio();
// import 'dart:convert';
// import 'package:http/http.dart' as http;

class StoreService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiBase.baseUrl));
  final box = GetStorage();

  // ✅ Ambil detail bengkel yang dimiliki oleh user login
  Future<StoreModel?> fetchStoreDetail() async {
    try {
      final role = box.read('role');
      if (role != "store") {
        debugPrint("🚫 Role bukan store, tidak bisa fetch data store.");
        return null;
      }

      final token = box.read('token');

      // ✅ Tambahkan log pemanggilan API di sini
      debugPrint('🔗 Memanggil: GET owned/store');

      final response = await dio.get(
        'owned/store',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final dataList = response.data['data'];

        if (dataList == null || dataList.isEmpty) {
          debugPrint('⚠️ Data bengkel kosong!');
          return null;
        }

        final store = StoreModel.fromJson(dataList[0]);
        box.write('store_id', store.id);
        debugPrint('✅ Store ID disimpan: ${store.id}');
        debugPrint('✅ Store name: ${store.storeName}');
        return store;
      } else {
        debugPrint('❌ Gagal fetch data bengkel: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetchStoreDetail: $e');
      return null;
    }
  }

  // ✅ Update data user
  Future<bool> updateUserProfile({
    required String name,
    required String email,
    required String phoneNumber,
    String? address,
  }) async {
    try {
      final token = box.read('token');

      final response = await dio.patch(
        '${ApiBase.baseUrl}profile/update',
        data: {
          'name': name,
          'email': email,
          'phone_number': phoneNumber,
          'address': address ?? '-',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Gagal update profil user: $e');
      return false;
    }
  }

  // ✅ Update password
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
      final response = await dio.post(
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

  // 🔄 Update data store (bengkel)
  Future<bool> updateStoreProfile({
    required int storeId,
    required String storeName,
    required String address,
    required String contact,
    String? contactName,
    required double lat,
    required double long,
    required String openAt,
    required String closeAt,
    required List<String> acceptedVehicleTypes,
    File? image,
  }) async {
    try {
      final token = box.read('token');

      final Map<String, dynamic> storeData = {
        'store_name': storeName,
        'address': address,
        'contact': contact,
        'lat': lat,
        'long': long,
        'open_at': openAt,
        'close_at': closeAt,
        'accepted_vehicle_types': acceptedVehicleTypes,
      };

      if (contactName != null && contactName.isNotEmpty) {
        storeData['contact_name'] = contactName;
      }

      if (image != null) {
        storeData['image'] = await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        );
      }

      // final formData = FormData.fromMap(storeData);

      final response = await dio.patch(
        '/store/update/$storeId', // ✅ Sesuai backend route
        data: storeData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('🔗 URL: /store/update/$storeId');
      debugPrint('📦 PAYLOAD: ${storeData.toString()}');
      debugPrint('📡 STATUS: ${response.statusCode}');
      debugPrint('📡 BODY: ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('✅ Store updated successfully');
        return true;
      } else {
        debugPrint(
          '❌ Gagal update store: ${response.statusCode} | ${response.data}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception saat update store: $e');
      return false;
    }
  }

  Future<List<StoreModel>> fetchStores() async {
    final box = GetStorage();
    final token = box.read('token');
    try {
      final response = await dio.get(
        'owned/store',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data['data'];
      return data.map((store) => StoreModel.fromJson(store)).toList();
    } catch (e) {
      debugPrint('❌ Gagal mengambil data: $e');
      return [];
    }
  }

  Future<List<StoreModel>> getAllOwnedStores(String token) async {
    final response = await dio.get(
      'owned/store',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => StoreModel.fromJson(e)).toList();
      } else {
        throw Exception("Format data tidak valid");
      }
    } else {
      throw Exception("Gagal memuat data bengkel: ${response.statusCode}");
    }
  }

  Future<bool> toggleEmergencyCallService({
    required int storeId,
    required bool newValue,
  }) async {
    final token = box.read('token');

    try {
      final requestData = {"emergency_call": newValue ? "1" : "0"};
      debugPrint("🔄 Toggle Emergency Call: $requestData");

      final response = await dio.patch(
        '/store/emergencycall/update/$storeId',
        data: requestData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint("📡 Response: ${response.data}");

      if (response.statusCode == 200) {
        Get.snackbar("Sukses", response.data['message']);
        return true; // ✅ hanya return success/fail
      } else {
        Get.snackbar("Gagal", "Tidak dapat mengubah status emergency");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error toggleEmergencyCallService: $e");
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  Future<List<StoreModel>> fetchEmergencyStores() async {
    try {
      final response = await _dio.get(
        'https://api.example.com/stores?emergencyCall=true',
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => StoreModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  // 🔹 Customer: Ambil store emergency call dari endpoint publik
  Future<List<StoreModel>> getEmergencyStores() async {
    final response = await dio.get("${ApiBase.baseUrl}stores/emergency");

    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((json) => StoreModel.fromJson(json)).toList();
    } else {
      throw Exception("Gagal memuat data emergency");
    }
  }
}
