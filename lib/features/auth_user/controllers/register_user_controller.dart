import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bengkel/features/auth_user/services/auth_user_service.dart';
import '../../../app/routers.dart';

class RegisterUserController extends GetxController {
  final AuthUserService _authService = AuthUserService();

  var isLoading = false.obs;

  Future<void> register(Map<String, dynamic> data) async {
    isLoading.value = true;
    debugPrint("📦 Data terkirim ke register: $data");

    try {
      final success = await _authService.register(data);
      isLoading.value = false;

      if (success) {
        Get.snackbar(
          "Berhasil",
          "Registrasi berhasil!",
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          snackPosition: SnackPosition.TOP,
        );
        Get.offAllNamed(Routers.login);
      }
    } catch (e) {
      isLoading.value = false;

      // ✅ Ini akan menampilkan "The email has already been taken." jika dilempar dari atas
      Get.snackbar(
        "Registrasi Gagal",
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
