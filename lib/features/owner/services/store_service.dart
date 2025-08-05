import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:get_storage/get_storage.dart';

class StoreService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiBase.baseUrl));
  final box = GetStorage();

  // ✅ Ambil detail bengkel yang dimiliki oleh user login
  Future<StoreModel?> fetchStoreDetail() async {
    try {
      final role = box.read('role');
      if (role != "store") {
        print("🚫 Role bukan store, tidak bisa fetch data store.");
        return null;
      }

      final token = box.read('token');
      final response = await dio.get(
        'owned/store',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final dataList = response.data['data'];

        if (dataList == null || dataList.isEmpty) {
          print('⚠️ Data bengkel kosong!');
          return null;
        }

        final store = StoreModel.fromJson(dataList[0]);
        box.write('store_id', store.id);
        print('✅ Store ID disimpan: ${store.id}');

        print('✅ Store name: ${store.storeName}');
        return store;
      } else {
        print('❌ Gagal fetch data bengkel: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetchStoreDetail: $e');
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
        'profile/update',
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
      print('❌ Gagal update profil user: $e');
      return false;
    }
  }

  // ✅ Update password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final token = box.read('token');

      final response = await dio.patch(
        'profile/password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Gagal ganti password: $e');
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
        'contact_name': contactName,
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

      final formData = FormData.fromMap(storeData);
      print("📤 FINAL FORM DATA: ${formData.fields}");

      final response = await dio.patch(
        '/store/update/$storeId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('🔗 URL: /store/update/$storeId');
      print('🔐 TOKEN: $token');
      print('📦 PAYLOAD: ${storeData.toString()}');
      print('📡 STATUS: ${response.statusCode}');
      print('📡 BODY: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Store updated successfully');
        return true;
      } else {
        print(
          '❌ Gagal update store: ${response.statusCode} | ${response.data}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Exception saat update store: $e');
      return false;
    }
  }

  Future<bool> toggleEmergencyCall(int storeId) async {
    try {
      final token = box.read('token');

      final response = await dio.patch(
        'store/emergency/$storeId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error toggleEmergencyCall: $e');
      return false;
    }
  }

  // Future<StoreModel?> getStoreByUser(int userId) async {
  //   try {
  //     final token = box.read('token'); // Tambahkan ini
  //     final response = await dio.get(
  //       '/owned/store',
  //       options: Options(headers: {'Authorization': 'Bearer $token'}),
  //     );

  //     final List<dynamic> data = response.data['data'];
  //     if (data.isNotEmpty) {
  //       return StoreModel.fromJson(data[0]);
  //     } else {
  //       print('⚠️ Tidak ada data store dari API');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('❌ Error getStoreByUser: $e');
  //     return null;
  //   }
  // }

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
      print('❌ Gagal mengambil data: $e');
      return [];
    }
  }
}
