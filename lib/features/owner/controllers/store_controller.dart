import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StoreController extends GetxController {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiBase.baseUrl));
  final box = GetStorage();

  RxList<StoreModel> storeList = <StoreModel>[].obs;

  // ⬇️ Tambahkan method ini
  Future<List<StoreModel>> fetchOwnedStore() async {
    try {
      final token = box.read('token');

      final response = await dio.get(
        '/owned/store',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        storeList.assignAll(data.map((e) => StoreModel.fromJson(e)).toList());
        return storeList;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error saat fetch store: $e');
      return [];
    }
  }

  // Fungsi lain seperti updateStoreProfile() dll...
}
