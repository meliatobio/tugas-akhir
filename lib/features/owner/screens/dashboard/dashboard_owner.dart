import 'package:bengkel/features/owner/screens/home/home_owner.dart';
import 'package:bengkel/features/owner/screens/profile/profile_owner.dart';
import 'package:bengkel/features/owner/screens/riwayat/kelola_booking.dart';
import 'package:bengkel/features/owner/widgets/bottom_navigation_bar_owner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardOwnerScreen extends StatefulWidget {
  const DashboardOwnerScreen({super.key});

  @override
  State<DashboardOwnerScreen> createState() => _DashboardOwnerScreenState();
}

class _DashboardOwnerScreenState extends State<DashboardOwnerScreen> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argIndex = Get.arguments;
    if (argIndex != null && argIndex is int) {
      _selectedIndex = argIndex;
    }
  }

  final List<Widget> _pages = [
    HomeOwnerScreen(),
    const KelolaBookingScreen(),
    const ProfileOwnerScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBarWidgetOwner(
        selectedIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
