import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bengkel/features/auth_user/services/auth_user_service.dart';

class EditProfileUserScreen extends StatefulWidget {
  const EditProfileUserScreen({super.key});

  @override
  State<EditProfileUserScreen> createState() => _EditProfileUserScreenState();
}

class _EditProfileUserScreenState extends State<EditProfileUserScreen> {
  final AuthUserService _authService = AuthUserService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _phoneC = TextEditingController();
  final TextEditingController _addressC = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = GetStorage();
    final token = box.read('token');

    if (token != null) {
      _authService.setToken(token); // penting
      final result = await _authService.getProfile(); // tidak perlu token lagi

      if (result != null) {
        setState(() {
          _nameC.text = result['name'] ?? '';
          _emailC.text = result['email'] ?? '';
          _phoneC.text = result['phone_number'] ?? '';
          _addressC.text = result['address'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        Get.snackbar(
          "Gagal",
          "Gagal memuat profil. Silakan login ulang.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      setState(() => _isLoading = false);
      Get.snackbar(
        "Tidak Ada Token",
        "Silakan login terlebih dahulu.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "name": _nameC.text.trim(),
        "email": _emailC.text.trim(),
        "phone_number": _phoneC.text.trim(),
        "address": _addressC.text.trim(),
      };

      final success = await _authService.updateProfile(data);
      if (success) {
        // 🔁 Segarkan profil user di GetStorage jika perlu
        final updatedProfile = await _authService.getProfile();
        final box = GetStorage();
        box.write(
          'profile',
          updatedProfile,
        ); // optional, jika kamu simpan secara lokal

        // ⬅️ Kembali ke ProfileUserScreen dan refresh data
        Get.offAllNamed('/dashboarduser', arguments: {'tab': 3});

        Get.snackbar(
          "Sukses",
          "Profil berhasil diperbarui",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Gagal",
          "Gagal memperbarui profil",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) =>
              value == null || value.isEmpty ? "Tidak boleh kosong" : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildField("Name", _nameC),
                    _buildField(
                      "Email",
                      _emailC,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(
                      "No. Telepon",
                      _phoneC,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField("Alamat", _addressC),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
