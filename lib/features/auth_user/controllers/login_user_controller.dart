import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bengkel/features/auth_user/services/auth_user_service.dart';
import 'package:bengkel/models/user_model.dart';
import '../../../app/routers.dart';

class LoginUserController extends GetxController {
  final AuthUserService _authService = AuthUserService();

  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;

    try {
      UserModel? user = await _authService.login(email, password);

      isLoading.value = false;

      if (user != null) {
        if (user.role != 'customer') {
          Get.snackbar(
            "Login Gagal",
            "Akun ini bukan pengguna customer.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        final box = GetStorage();
        await box.write('user', user.toJson());
        await box.write('token', user.token);
        await box.write('isLoggedIn', true);

        _authService.setToken(user.token);

        Get.offAllNamed(Routers.dashboarduser);
      } else {
        Get.snackbar(
          "Login Gagal",
          "Email atau password salah",
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: $e",
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}
