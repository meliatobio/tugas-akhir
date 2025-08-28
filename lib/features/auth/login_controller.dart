import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bengkel/features/auth_user/services/auth_user_service.dart';
import 'package:bengkel/features/auth_owner/services/auth_owner_service.dart';
import 'package:bengkel/models/user_model.dart';
import '../../../app/routers.dart';

class LoginController extends GetxController {
  final AuthUserService _authUserService = AuthUserService();
  final AuthOwnerService _authOwnerService = AuthOwnerService();

  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;

    try {
      // Coba login sebagai user/customer
      UserModel? user = await _authUserService.login(email, password);

      if (user != null) {
        debugPrint("🔑 Token User yang dikirim: ${user.token}");
        _handleLogin(user);
        return;
      }

      // Kalau gagal login user, coba login owner
      final ownerData = await _authOwnerService.loginOwner(email, password);

      if (ownerData != null) {
        final owner = UserModel.fromJson(ownerData['user']);
        owner.token = ownerData['token'] ?? '';
        debugPrint("🔑 Token Owner yang dikirim: ${owner.token}");
        _handleLogin(owner);
        return;
      }

      // Kalau keduanya gagal
      Get.snackbar(
        "Login Gagal",
        "Email atau password salah",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleLogin(UserModel user) async {
    final box = GetStorage();

    // Simpan user & token
    await box.write('user', user.toJson());
    await box.write('token', user.token);

    // Simpan user_id & role
    await box.write('user_id', user.id);
    await box.write('role', user.role);
    await box.write('isLoggedIn', true);

    // Navigasi berdasarkan role
    if (user.role == 'customer') {
      Get.offAllNamed(Routers.dashboarduser);
    } else if (user.role == 'owner' || user.role == 'store') {
      Get.offAllNamed(Routers.dashboardowner);
    } else {
      Get.snackbar(
        "Login Gagal",
        "Role tidak dikenali: ${user.role}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
