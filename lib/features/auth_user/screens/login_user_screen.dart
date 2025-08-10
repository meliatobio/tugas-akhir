// import 'package:bengkel/app/routers.dart';
// import 'package:bengkel/features/auth_user/controllers/login_user_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../shared/widgets/clipper.dart';

// class LoginUserScreen extends StatelessWidget {
//   LoginUserScreen({super.key});

//   final loginController = Get.put(LoginUserController());

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   final RxBool isObscure = true.obs;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             // Bagian Wave Background
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
//             // Isi Konten
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 30),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 60),

//                   // Avatar Placeholder
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.white,
//                     child: Image.asset(
//                       'assets/images/logo.png',
//                       width: 80,
//                       height: 80,
//                     ),
//                   ),

//                   // Title
//                   const Text(
//                     "Login",
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 110),

//                   // Email Field
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

//                   // Password Field dengan Eye Icon
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

//                   const SizedBox(height: 24),

//                   // Tombol Login
//                   ElevatedButton(
//                     onPressed: () {
//                       final email = emailController.text.trim();
//                       final password = passwordController.text.trim();

//                       if (email.isEmpty || password.isEmpty) {
//                         Get.snackbar(
//                           "Gagal",
//                           "Email dan password wajib diisi",
//                           backgroundColor: Colors.red,
//                           colorText: Colors.white,
//                         );
//                         return;
//                       }

//                       loginController.login(email, password);
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

//                   // Sign Up
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Don’t have an account? "),
//                       GestureDetector(
//                         onTap: () {
//                           Get.toNamed(Routers.registeruser);
//                         },
//                         child: const Text(
//                           "SIGN UP",
//                           style: TextStyle(
//                             color: Color(0xFFFFC107),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),

//                   // Back Button
//                   TextButton(
//                     onPressed: () {
//                       Get.offAllNamed(Routers.start);
//                     },
//                     child: const Text(
//                       "← Back to Home",
//                       style: TextStyle(
//                         color: Colors.black54,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Custom clipper untuk wave
