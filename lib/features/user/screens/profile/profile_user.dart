import 'dart:io';
import 'package:bengkel/app/routers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bengkel/features/auth_user/services/auth_user_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileUserScreen extends StatefulWidget {
  const ProfileUserScreen({super.key});

  @override
  State<ProfileUserScreen> createState() => _ProfileUserScreenState();
}

class _ProfileUserScreenState extends State<ProfileUserScreen> {
  final AuthUserService _authService = AuthUserService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token != null) {
        _authService.setToken(token);
        final result = await _authService.getProfile();

        if (!mounted) return;
        setState(() {
          _profile = result;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: Colors.orange, size: 20),
            SizedBox(width: 6),
            Text(
              "Ubah Password",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16, // kecil dan elegan
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Lama',
                  labelStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.lock_clock_outlined, size: 20),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Baru',
                  labelStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.lock_open_rounded, size: 20),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  labelStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.lock_reset_rounded, size: 20),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPass = oldPasswordController.text.trim();
              final newPass = newPasswordController.text.trim();
              final confirmPass = confirmPasswordController.text.trim();

              if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Semua field harus diisi",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              if (newPass != confirmPass) {
                Get.snackbar(
                  "Error",
                  "Konfirmasi password tidak cocok",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final success = await _authService.changePassword(
                oldPassword: oldPass,
                newPassword: newPass,
                confirmPassword: confirmPass,
              );

              if (success) {
                Get.back();
                Get.snackbar(
                  "Berhasil",
                  "Password berhasil diubah",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  "Gagal",
                  "Password gagal diubah",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text("Simpan", style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String? value, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            obscure ? '•' * 10 : (value ?? '-'),
            style: const TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildProfileImage(String? url) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);

        if (picked != null) {
          final file = File(picked.path);
          final newUrl = await _authService.uploadProfilePicture(file);

          if (newUrl != null) {
            setState(() {
              _profile!['profile_pict'] = newUrl;
            });
            Get.snackbar(
              "Berhasil",
              "Foto profil diperbarui",
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              "Gagal",
              "Upload foto gagal",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: (url != null && url.isNotEmpty)
                ? NetworkImage(url)
                : null,
            child: (url == null || url.isEmpty)
                ? const Icon(Icons.person, size: 50, color: Colors.white70)
                : null,
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber,
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          // Wave kuning pucat (layer bawah)
          ClipPath(
            clipper: WaveClipper2(),
            child: Container(height: 220, color: Colors.yellow.shade200),
          ),
          // Wave kuning tua (layer atas)
          ClipPath(
            clipper: WaveClipper1(),
            child: Container(height: 200, color: Colors.amber),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text(
                    "Profile",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: Colors.black,
                  centerTitle: false,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _profile == null
                      ? const Center(child: Text("Gagal memuat data profil."))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 25,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    _buildProfileImage(
                                      _profile!['profile_pict'],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Hi, ${_profile!['name'] ?? '-'}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                              _buildTextField("Name", _profile!['name']),
                              _buildTextField("Email", _profile!['email']),
                              _buildTextField(
                                "No. Telepon",
                                _profile!['phone_number'],
                              ),
                              _buildTextField("Alamat", _profile!['address']),
                              const SizedBox(height: 5),
                              Column(
                                children: [
                                  // 🔹 Tombol Edit
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          Get.toNamed('/editprofileuser'),
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Colors.black87,
                                      ),
                                      label: const Text(
                                        "Edit Profil",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // 🔹 Tombol Ubah Password
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _showChangePasswordDialog,
                                      icon: const Icon(
                                        Icons.lock_outline,
                                        size: 20,
                                        color: Colors.white,
                                      ),

                                      label: const Text(
                                        "Ubah Password",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // 🔹 Tombol Logout
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final confirmed = await Get.dialog<bool>(
                                          AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            titlePadding:
                                                const EdgeInsets.fromLTRB(
                                                  20,
                                                  16,
                                                  20,
                                                  8,
                                                ),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                  20,
                                                  0,
                                                  20,
                                                  8,
                                                ),
                                            actionsPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                            title: Row(
                                              children: const [
                                                Icon(
                                                  Icons.logout_rounded,
                                                  color: Colors.red,
                                                  size: 22,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Konfirmasi Logout",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: const Text(
                                              "Apakah kamu yakin ingin logout?",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Get.back(result: false),
                                                child: const Text(
                                                  "Batal",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Get.back(result: true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10,
                                                      ),
                                                  textStyle: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text("Logout"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          final success = await _authService
                                              .logout();
                                          if (success) {
                                            final box = GetStorage();
                                            await box.erase();
                                            _authService.setToken('');
                                            Get.offAllNamed(Routers.login);
                                          } else {
                                            Get.snackbar(
                                              "Logout Gagal",
                                              "Gagal logout. Coba lagi nanti.",
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.logout,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Logout",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Wave kuning tua (atas)
class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Wave kuning pucat (bawah)
class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height - 10);
    var firstEndPoint = Offset(size.width / 2, size.height - 60);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 110);
    var secondEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
