import 'package:bengkel/features/auth_user/services/auth_user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routers.dart'; // sesuaikan path

class LupaPasswordScreen extends StatelessWidget {
  LupaPasswordScreen({Key? key}) : super(key: key);

  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Pastikan AuthUserService sudah didaftarkan dengan Get.put(AuthUserService()) di main.dart atau binding
  final AuthUserService authService = Get.find<AuthUserService>();

  void _submit() async {
    final email = emailController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field wajib diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Password baru dan konfirmasi tidak cocok',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    bool success = await authService.lupaPassword(
      email: email,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (success) {
      Get.snackbar(
        'Berhasil',
        'Password berhasil diubah, silakan login kembali',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(Routers.login);
    } else {
      Get.snackbar(
        'Gagal',
        'Reset password gagal, coba lagi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apa email Anda?, kami akan membantu mereset password anda',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Email
            _buildTextField(
              controller: emailController,
              label: 'Email',
              obscure: false,
            ),
            const SizedBox(height: 20),

            // Password Baru
            _buildTextField(
              controller: newPasswordController,
              label: 'Password Baru',
              obscure: true,
            ),
            const SizedBox(height: 20),

            // Ulang Password Baru
            _buildTextField(
              controller: confirmPasswordController,
              label: 'Ulang Password Baru',
              obscure: true,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Konfirmasi',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
