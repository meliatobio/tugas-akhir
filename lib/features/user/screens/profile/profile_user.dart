import 'package:bengkel/app/routers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bengkel/features/auth_user/services/auth_user_service.dart';

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
        title: const Text("Ubah Password"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Lama'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              final oldPass = oldPasswordController.text.trim();
              final newPass = newPasswordController.text.trim();
              final confirmPass = confirmPasswordController.text.trim();

              if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                Get.snackbar("Error", "Semua field harus diisi");
                return;
              }

              if (newPass != confirmPass) {
                Get.snackbar("Error", "Konfirmasi password tidak cocok");
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
            child: const Text("Simpan"),
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
    return CircleAvatar(
      radius: 55,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: (url != null && url.isNotEmpty)
          ? NetworkImage(url)
          : null,
      child: (url == null || url.isEmpty)
          ? const Icon(Icons.camera_alt, size: 36, color: Colors.white70)
          : null,
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
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Get.toNamed('/editprofileuser');
                                      },
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text(
                                        "Edit",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _showChangePasswordDialog,
                                      icon: const Icon(Icons.lock_outline),
                                      label: const Text("Ubah Password"),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.orange,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final confirmed = await Get.dialog<bool>(
                                          AlertDialog(
                                            title: const Text(
                                              "Konfirmasi Logout",
                                            ),
                                            content: const Text(
                                              "Apakah kamu yakin ingin logout?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Get.back(result: false),
                                                child: const Text("Batal"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Get.back(result: true),
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Logout",
                                        style: TextStyle(color: Colors.white),
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
