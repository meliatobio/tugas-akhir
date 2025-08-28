import 'dart:convert';
import 'dart:io';
import 'package:bengkel/models/booking_model.dart';
import 'package:bengkel/models/service_model.dart';
import 'package:bengkel/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

//final Dio _dio = Dio();
// import 'dart:convert';
// import 'package:http/http.dart' as http;

class StoreService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiBase.baseUrl));
  final box = GetStorage();
  Future<String?> getToken() async {
    return box.read('token');
  }

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
        '/owned/store',
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
        '/profile/update',
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
        '/auth/reset-password',
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

      final formData = FormData();

      // ✅ Override method supaya Laravel treat as PATCH
      formData.fields.add(MapEntry('_method', 'PATCH'));

      // ✅ Tambahkan field biasa
      formData.fields.add(MapEntry('store_name', storeName));
      formData.fields.add(MapEntry('address', address));
      formData.fields.add(MapEntry('contact', contact));
      formData.fields.add(MapEntry('lat', lat.toString()));
      formData.fields.add(MapEntry('long', long.toString()));
      formData.fields.add(MapEntry('open_at', openAt));
      formData.fields.add(MapEntry('close_at', closeAt));

      if (contactName != null && contactName.isNotEmpty) {
        formData.fields.add(MapEntry('contact_name', contactName));
      }

      // ✅ Array untuk accepted_vehicle_types
      for (var i = 0; i < acceptedVehicleTypes.length; i++) {
        formData.fields.add(
          MapEntry('accepted_vehicle_types[$i]', acceptedVehicleTypes[i]),
        );
      }

      // ✅ Upload file jika ada
      if (image != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      // 🔥 Kirim dengan POST (karena ada _method=PATCH)
      final response = await dio.post(
        '/store/update/$storeId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (kDebugMode) {
        debugPrint('📦 fields: ${formData.fields}');
        debugPrint('📦 files: ${formData.files}');
        debugPrint('📡 STATUS: ${response.statusCode}');
        debugPrint('📡 BODY: ${response.data}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        debugPrint('❌ Dio Error: ${e.response?.data}');
      } else {
        debugPrint('❌ Exception saat update store: $e');
      }
      return false;
    }
  }

  Future<List<StoreModel>> fetchStores() async {
    final box = GetStorage();
    final token = box.read('token');
    try {
      final response = await dio.get(
        '/owned/store',
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
      '/owned/store',
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

  Future<StoreModel?> fetchStoreById(int storeId) async {
    try {
      final token = await getToken(); // pastikan getToken() ada
      final response = await http.get(
        Uri.parse("${ApiBase.baseUrl}store/$storeId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StoreModel.fromJson(data['store']);
      } else {
        debugPrint("Gagal ambil store: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetchStoreById: $e");
      return null;
    }
  }

  Future<List<StoreModel>> fetchEmergencyStores() async {
    try {
      final response = await dio.get('/stores?emergencyCall=true');

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => StoreModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error: $e');
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

  // Tambahkan ini di StoreService
  Future<StoreModel?> fetchStoreDetailById(int storeId) async {
    try {
      final token = box.read('token');
      final response = await dio.get(
        '/store/$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data == null) return null;

        // pastikan Map<String, dynamic>
        final mapData = Map<String, dynamic>.from(data);

        // 🔹 Map key "store_service" dari API ke "services" supaya cocok sama model
        if (mapData.containsKey('store_service')) {
          mapData['services'] = mapData['store_service'];
        }

        return StoreModel.fromJson(mapData);
      } else {
        debugPrint('Gagal load detail store: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('FetchStoreDetail exception: $e');
      return null;
    }
  }

  Future<bool> toggleStoreActive({required int storeId}) async {
    final token = box.read('token');
    try {
      final response = await dio.patch(
        '/store/active/update/$storeId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint("✅ Toggle response: ${response.data}");

      if (response.statusCode == 200) {
        // simpan state terakhir
        final updatedStore = response.data['data'] ?? {};
        box.write('last_store_state', updatedStore);
        return response.data['active'] ?? false;
      } else {
        return false;
      }
    } on DioException catch (e) {
      debugPrint("❌ Gagal toggle store active: $e");
      return false;
    }
  }

  Future<ServiceModel?> addService({
    required int storeId,
    required String name,
    required String vehicleType,
    required String description,
    required double price,
  }) async {
    try {
      final box = GetStorage();
      final token = box.read('token') ?? '';

      // 🔧 Normalisasi & guard
      String vt = vehicleType.trim().toLowerCase();
      if (vt == 'motor') vt = 'motorcycle';
      if (vt == 'mobil') vt = 'car';
      if (vt != 'car' && vt != 'motorcycle') {
        debugPrint(
          "❌ vehicle_type tidak valid di client: '$vehicleType' (-> '$vt')",
        );
        Get.snackbar("Error", "Jenis kendaraan harus 'car' atau 'motorcycle'");
        return null;
      }

      final uri = ApiBase.uri('store/service');
      final body = {
        'store_id': storeId,
        'name': name,
        'vehicle_type': vt, // ✅ pasti valid
        'description': description,
        'price': price,
        'is_active': true,
      };

      debugPrint("🚗 vehicle_type terkirim: '$vt'");
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint("📥 Response Code: ${response.statusCode}");
      debugPrint("📥 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body)['service'];
        return ServiceModel.fromJson(data);
      } else {
        debugPrint("❌ Gagal: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ addService error: $e");
      return null;
    }
  }

  Future<StoreModel?> fetchStoreDetailForOwner() async {
    try {
      final token = box.read('token');
      final response = await dio.get(
        '/owned/store',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data == null) return null;

        final mapData = Map<String, dynamic>.from(data);
        return StoreModel.fromJson(mapData);
      } else {
        debugPrint('Gagal load detail store owner: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('FetchStoreDetailForOwner exception: $e');
      return null;
    }
  }

  Future<StoreModel?> fetchOwnedStoreWithServices() async {
    try {
      final token = box.read('token');
      debugPrint(token);

      // 1. Ambil store milik user
      final ownedResponse = await dio.get(
        '/owned/store',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint("Response status nya, ${ownedResponse.statusCode}");
      debugPrint("Apakah response nya 200? ${ownedResponse.statusCode == 200}");
      debugPrint('Apakah data kosong? ${ownedResponse.data.isEmpty}');

      if (ownedResponse.statusCode != 200 || ownedResponse.data == null) {
        throw Exception('Gagal ambil owned store');
      }

      dynamic dataOwned = ownedResponse.data['data'];

      // Pastikan bentuk data benar
      Map<String, dynamic> storeJson;
      if (dataOwned is List) {
        if (dataOwned.isEmpty) throw Exception('Tidak ada store yang dimiliki');
        storeJson = Map<String, dynamic>.from(dataOwned.first);
      } else if (dataOwned is Map) {
        storeJson = Map<String, dynamic>.from(dataOwned);
      } else {
        throw Exception('Format data store tidak dikenal');
      }

      StoreModel store = StoreModel.fromJson(storeJson);

      // 2. Ambil detail store termasuk layanan
      final servicesResponse = await dio.get(
        '/store/${store.id}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      debugPrint('📦 Raw owned store data: $dataOwned');

      if (servicesResponse.statusCode == 200 && servicesResponse.data != null) {
        final detailData = Map<String, dynamic>.from(
          servicesResponse.data['data'],
        );
        if (detailData['services'] != null) {
          final servicesList = List<ServiceModel>.from(
            detailData['services'].map((x) => ServiceModel.fromJson(x)),
          );
          store = store.copyWith(services: servicesList);
        }
      }

      return store;
    } catch (e) {
      debugPrint('❌ fetchOwnedStoreWithServices error: $e');
      return null;
    }
  }

  Future<StoreModel?> fetchOwnedStoreById(int storeId) async {
    try {
      final token = box.read('token');
      final response = await dio.get(
        '/owned/store/$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint("📡 Fetch Owned Store by ID: /owned/store/$storeId");
      debugPrint("📡 Status Code: ${response.statusCode}");
      debugPrint("📦 Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data['data']);
        return StoreModel.fromJson(data);
      } else {
        debugPrint('❌ Gagal load owned store by ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ fetchOwnedStoreById exception: $e');
      return null;
    }
  }

  Future<List<BookingModel>> fetchBookingsForOwner() async {
    final box = GetStorage();
    final token = box.read<String>('token');
    final userId = box.read<int>('user_id');

    if (token == null || userId == null) {
      throw Exception('Token atau userId tidak ditemukan');
    }

    final response = await http.get(
      ApiBase.uri('store/$userId/booking'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> bookingJson = jsonDecode(response.body)['data'];
      return bookingJson.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal ambil booking data');
    }
  }

  Future<bool> deleteStore(int storeId) async {
    try {
      final token = box.read('token'); // ambil token dari GetStorage
      if (token == null) return false;

      final response = await http.delete(
        ApiBase.uri('store/$storeId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleteStore: $e');
      return false;
    }
  }

  Future<bool> deleteService(int serviceId) async {
    final box = GetStorage();
    final token = box.read('token');

    final response = await http.delete(
      Uri.parse(
        'http://localhost:8000/api/service/$serviceId',
      ), // 🔹 singular "service"
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    debugPrint("DELETE ${response.request?.url}");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<ServiceModel?> updateService(
    int id, {
    required String name,
    String? description,
    double? price,
    String? vehicleType, // tambahkan opsional
  }) async {
    try {
      final token = await getToken();
      String? vt = vehicleType?.trim().toLowerCase();
      if (vt == 'motor') vt = 'motorcycle';
      if (vt == 'mobil') vt = 'car';

      final payload = {
        'name': name,
        'description': description,
        'price': price,
        if (vt != null) 'vehicle_type': vt, // kirim jika ada
      };

      final response = await http.put(
        Uri.parse('${ApiBase.baseUrl}service/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['service'];
        return ServiceModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("updateService error: $e");
      return null;
    }
  }

  Future<bool> updateServiceStatus(int serviceId, bool isActive) async {
    try {
      debugPrint("🔄 Memanggil API updateServiceStatus...");
      debugPrint("➡️ serviceId: $serviceId, isActive: $isActive");

      final token = box.read('token');
      debugPrint("📦 Token: $token");

      final response = await Dio().patch(
        "${ApiBase.baseUrl}store/service/$serviceId",
        data: {"is_active": isActive},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      debugPrint("✅ Response status: ${response.statusCode}");
      debugPrint("📨 Response data: ${response.data}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Error updateServiceStatus: $e");
      return false;
    }
  }

  static Future<bool> checkCanReview(int storeId) async {
    final token = StorageService.token;
    if (token == null || token.isEmpty) return false;

    final url = '${ApiBase.baseUrl}store/$storeId/can-review';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['can_review'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('❌ checkCanReview error: $e');
      return false;
    }
  }

  // Di StoreService
  static Future<Map<String, dynamic>?> submitReview({
    required int storeId,
    required int serviceId,
    required int rate,
    required String message,
  }) async {
    final token = StorageService.token;
    if (token == null || token.isEmpty) return null;

    final url = '${ApiBase.baseUrl}review';
    try {
      final body = {
        'store_id': storeId,
        'service_id': serviceId,
        'rate': rate,
        'message': message,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['review']; // langsung ambil review dari response
      } else {
        debugPrint('❌ submitReview failed: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ submitReview error: $e');
      return null;
    }
  }
}
