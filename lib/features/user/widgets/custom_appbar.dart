// import 'package:flutter/material.dart';

// Widget _buildCustomAppBar(BuildContext context) {
//   return Container(
//     width: double.infinity,
//     decoration: const BoxDecoration(
//       color: Colors.amber,
//       borderRadius: BorderRadius.only(
//         bottomLeft: Radius.circular(20),
//         bottomRight: Radius.circular(20),
//       ),
//     ),
//     padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
//     child: SafeArea(
//       bottom: false,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Baris atas: Logo + Logout
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: const [
//                   CircleAvatar(
//                     backgroundColor: Colors.white,
//                     radius: 14,
//                     child: Icon(Icons.build, color: Colors.amber),
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'OntoCare',
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               IconButton(
//                 icon: const Icon(Icons.logout, color: Colors.white),
//                 onPressed: () => _showLogoutConfirmation(context),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // Search Bar
//           GestureDetector(
//             onTap: () {
//               Get.toNamed(Routers.searchbengkel);
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.search, color: Colors.grey),
//                   SizedBox(width: 8),
//                   Text(
//                     "Cari Bengkel...",
//                     style: TextStyle(color: Colors.grey, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
