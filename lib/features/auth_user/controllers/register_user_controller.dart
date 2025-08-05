import 'package:get/get.dart';
import 'package:bengkel/features/auth_user/services/auth_user_service.dart';
import '../../../app/routers.dart';

class RegisterUserController extends GetxController {
  final AuthUserService _authService = AuthUserService();

  var isLoading = false.obs;

  Future<void> register(Map<String, dynamic> data) async {
    isLoading.value = true;

    // 🔍 Tampilkan data yang dikirim
    print("📦 Data terkirim ke register: $data");

    try {
      final success = await _authService.register(data);
      isLoading.value = false;

      if (success) {
        Get.snackbar(
          "Berhasil",
          "Registrasi berhasil!",
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        Get.offAllNamed(Routers.loginuser);
      } else {
        Get.snackbar(
          "Gagal",
          "Registrasi gagal, periksa kembali data Anda.",
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
