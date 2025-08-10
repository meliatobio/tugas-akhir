import 'package:bengkel/features/auth_owner/services/auth_owner_service.dart';
import 'package:get/get.dart';
import 'package:bengkel/app/routers.dart';
import 'package:image_picker/image_picker.dart';

class RegisterOwnerController extends GetxController {
  final AuthOwnerService _authService = AuthOwnerService();

  var isLoading = false.obs;

  Future<void> registerOwner({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> storeData,
    required XFile? pickedImage,
  }) async {
    isLoading.value = true;

    final registerSuccess = await _authService.registerOwnerAccount(userData);

    if (!registerSuccess) {
      isLoading.value = false;
      Get.snackbar("Gagal", "Registrasi akun owner gagal.");
      return;
    }

    final loginResult = await _authService.loginOwner(
      userData['email'],
      userData['password'],
    );

    if (loginResult == null) {
      isLoading.value = false;
      Get.snackbar("Gagal", "Login otomatis gagal.");
      return;
    }

    final token = loginResult['token'];
    final user = loginResult['user'];
    final userId = user['id'];
    storeData['user_id'] = userId;

    final storeSuccess = await _authService.registerStore(
      storeData,
      token,
      pickedImage!,
    );

    isLoading.value = false;

    if (storeSuccess) {
      Get.snackbar("Berhasil", "Registrasi Owner & Bengkel berhasil!");
      Get.toNamed(Routers.login);
    } else {
      Get.snackbar("Gagal", "Registrasi bengkel gagal.");
    }
  }
}
