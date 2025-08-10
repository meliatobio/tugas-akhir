// import 'package:bengkel/app/routers.dart';
// import 'package:bengkel/shared/widgets/clipper.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:bengkel/features/auth_owner/services/auth_owner_service.dart';

// class LoginOwnerScreen extends StatelessWidget {
//   LoginOwnerScreen({super.key});

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final box = GetStorage(); // Tambahkan ini untuk akses storage
//   final RxBool isObscure = true.obs;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Stack(
//               children: [
//                 // Layer belakang (warna lebih terang)
//                 Positioned(
//                   top: 20, // geser sedikit ke bawah
//                   left: 0,
//                   right: 0,
//                   child: ClipPath(
//                     clipper: TopWaveClipper(),
//                     child: Container(
//                       height: 300,
//                       color: const Color(0xFFFFF4CF), // kuning pucat
//                     ),
//                   ),
//                 ),

//                 // Layer depan (gradasi utama)
//                 ClipPath(
//                   clipper: TopWaveClipper(),
//                   child: Container(
//                     height: 300,
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Color(0xFFFFE082), Color(0xFFFFC107)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             //isi konten
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 30),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 60),

//                   CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.white,
//                     child: Image.asset(
//                       'assets/images/logo.png',
//                       width: 80,
//                       height: 80,
//                     ),
//                   ),

//                   const Text(
//                     "Login",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 26.0,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),

//                   const SizedBox(height: 110),
//                   // Email Input
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withAlpha(76),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: TextFormField(
//                       controller: emailController,
//                       decoration: InputDecoration(
//                         labelText: "E-mail",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide.none,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 15,
//                           horizontal: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16.0),
//                   // Password Input
//                   Obx(
//                     () => Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withAlpha(76),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: TextFormField(
//                         controller: passwordController,
//                         obscureText: isObscure.value,
//                         decoration: InputDecoration(
//                           labelText: "Password",
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               isObscure.value
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                               color: Colors.grey[500],
//                             ),
//                             onPressed: () {
//                               isObscure.value = !isObscure.value;
//                             },
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 15,
//                             horizontal: 20,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24.0),
//                   // Tombol Login
//                   ElevatedButton(
//                     onPressed: () async {
//                       final email = emailController.text.trim();
//                       final password = passwordController.text;

//                       if (email.isEmpty || password.isEmpty) {
//                         Get.snackbar(
//                           "Gagal",
//                           "Email dan password wajib diisi",
//                           backgroundColor: Colors.red,
//                           colorText: Colors.white,
//                         );
//                         return;
//                       }

//                       final authService = AuthOwnerService();
//                       final result = await authService.loginOwner(
//                         email,
//                         password,
//                       );

//                       if (result != null) {
//                         final token = result['token'];
//                         final user = result['user'];

//                         // 🔐 CEK ROLE DI SINI
//                         if (user['role'] != 'store' &&
//                             user['role'] != 'owner') {
//                           Get.snackbar(
//                             "Akses Ditolak",
//                             "Akun ini bukan pemilik bengkel.",
//                             backgroundColor: Colors.red,
//                             colorText: Colors.white,
//                           );
//                           return;
//                         }

//                         // Simpan ke storage
//                         box.write('token', token);
//                         box.write('user', user);
//                         box.write('role', user['role']);

//                         debugPrint('✅ Token disimpan: $token');
//                         debugPrint('👤 User disimpan: $user');
//                         debugPrint('🎭 Role disimpan: ${user['role']}');

//                         Get.offAllNamed(Routers.dashboardowner);
//                       } else {
//                         Get.snackbar(
//                           "Gagal Login",
//                           "Email atau password salah",
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFFFC107),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       minimumSize: const Size(double.infinity, 50),
//                       elevation: 0,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Text(
//                           "Login",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Icon(Icons.arrow_forward, color: Colors.black),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Belum punya akun?"),
//                       TextButton(
//                         onPressed: () {
//                           Get.toNamed(Routers.registerowner);
//                         },
//                         child: const Text(
//                           "Daftar Disini",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Get.offAllNamed(Routers.start);
//                     },
//                     child: const Text(
//                       "← Kembali ke Halaman Awal",
//                       style: TextStyle(
//                         color: Colors.black54,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
