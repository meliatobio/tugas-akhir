import 'dart:io';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

final box = GetStorage();

class AuthOwnerService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiBase.baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  /// ✅ Ambil data bengkel milik owner
  Future<StoreModel?> getOwnedStore(String token) async {
    try {
      final response = await dio.get(
        '/owned/store',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data['data'];

      if (data is List && data.isNotEmpty) {
        return StoreModel.fromJson(data[0]);
      } else if (data is Map<String, dynamic>) {
        return StoreModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error getOwnedStore: $e');
      return null;
    }
  }

  /// 🛠️ Update profil user + store secara terpisah
  Future<bool> updateDataBengkel({
    required String token,
    required int userId,
    required int storeId,
    required String name,
    required String email,
    required String phone,
    String? password,
    required String storeName,
    required String address,
    required String contact,
    required String contactName,
    required double lat,
    required double long,
    required String openAt,
    required String closeAt,
    required List<String> acceptedVehicleTypes,
    File? image,
  }) async {
    try {
      // Update Store Profile
      final storeFormData = FormData.fromMap({
        'store_name': storeName,
        'address': address,
        'contact': contact,
        'contact_name': contactName,
        'lat': lat,
        'long': long,
        'open_at': openAt,
        'close_at': closeAt,
        'accepted_vehicle_types':
            acceptedVehicleTypes, // <-- pastikan ini List<String>
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });
      print('SEND: $acceptedVehicleTypes'); // harus tampil [mobil, motor]

      final response = await dio.patch(
        'store/update/$storeId',
        data: storeFormData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Profil store berhasil diperbarui");
        return true;
      } else {
        print("❌ Gagal update profil store: \${response.statusCode}");
        print("📥 Respon: \${response.data}");
        return false;
      }
    } catch (e) {
      print('❌ Exception updateDataBengkel: $e');
      return false;
    }
  }

  /// 🔄 Update data profil user
  Future<bool> updateUserProfile({
    required String token,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'phone_number': phone,
        'address': address,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      final response = await dio.patch(
        '/profile/update',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('✅ Update profil user berhasil');

        final updatedUser = response.data['user'];
        if (updatedUser != null) {
          box.write('user', updatedUser);
        }

        return true;
      }
    } catch (e) {
      print('❌ Gagal update profil user: $e');
    }

    // ✅ Tambahkan ini untuk menghindari error return type
    return false;
  }

  /// ✅ Register owner sekaligus daftarkan data bengkel
  Future<bool> registerOwner({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String storeName,
    required String storeAddress,
    required String contactName,
    required String contactPhone,
    required String lat,
    required String long,
    required String openAt,
    required String closeAt,
    required List<String> acceptedVehicleTypes,
    required File image,
  }) async {
    try {
      final ownerData = {
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phone,
        'address': address,
        'role': 'store',
      };

      final ownerRegistered = await registerOwnerAccount(ownerData);
      if (!ownerRegistered) {
        print('❌ Gagal register akun owner');
        return false;
      }

      final loginResult = await loginOwner(email, password);
      if (loginResult == null) {
        print('❌ Gagal login setelah register');
        return false;
      }

      final token = loginResult['token'];
      final user = loginResult['user'];

      final storeData = {
        'user_id': user['id'],
        'store_name': storeName,
        'address': storeAddress,
        'contact_name': contactName,
        'contact': contactPhone,
        'lat': lat,
        'long': long,
        'open_at': openAt,
        'close_at': closeAt,
        'accepted_vehicle_types': acceptedVehicleTypes,
      };

      final pickedImage = XFile(image.path);

      final storeSuccess = await registerStore(storeData, token, pickedImage);

      return storeSuccess;
    } catch (e) {
      print("❌ Register owner error: $e");
      return false;
    }
  }

  /// 🔐 Register akun user (role: store)
  Future<bool> registerOwnerAccount(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post('/auth/register', data: userData);
      return response.statusCode == 201;
    } on DioException catch (e) {
      print('❌ Register error: ${e.message}');
      print('📥 Response: ${e.response?.data}');
      return false;
    } catch (e) {
      print('❌ Exception saat register user: $e');
      return false;
    }
  }

  /// 🔐 Login user
  Future<Map<String, dynamic>?> loginOwner(
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {'token': data['token'], 'user': data['user']};
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error loginOwner: $e');
      return null;
    }
  }

  /// 🏪 Register data store
  Future<bool> registerStore(
    Map<String, dynamic> storeData,
    String token,
    XFile imageFile,
  ) async {
    try {
      final formData = FormData();

      storeData.forEach((key, value) {
        if (key == 'accepted_vehicle_types' && value is List<String>) {
          for (var type in value) {
            formData.fields.add(MapEntry('accepted_vehicle_types[]', type));
          }
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name,
          ),
        ),
      );

      final response = await dio.post(
        '/store/register',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      print('❌ Register store error: ${e.message}');
      print('📥 Response: ${e.response?.data}');
      return false;
    } catch (e) {
      print('❌ Unknown error saat register store: $e');
      return false;
    }
  }
}
