import 'package:bengkel/app/routers.dart';
import 'package:bengkel/features/auth_user/services/auth_user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  await GetStorage.init(); // ⬅️ PENTING!
  Get.put(AuthUserService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OntoCare',
      initialRoute: Routers.splash,
      getPages: Routers.routes, // ⬅️ WAJIB ADA INI
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
    );
  }
}
