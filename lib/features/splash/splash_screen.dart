import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed('/login');
    });

    return const Scaffold(
      body: Center(
        child: Image(image: AssetImage('assets/images/logo.png'), width: 150),
      ),
    );
  }
}
