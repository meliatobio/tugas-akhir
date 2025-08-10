import 'package:bengkel/features/user/screens/booking/booking.dart';
import 'package:bengkel/features/user/screens/home/home_user.dart';
import 'package:bengkel/features/user/screens/profile/profile_user.dart';
import 'package:bengkel/features/user/screens/riwayat/riwayat_user.dart';
import 'package:bengkel/features/user/widgets/bottom_navigation_bar_user.dart';
import 'package:flutter/material.dart';

class DashboardUserScreen extends StatefulWidget {
  const DashboardUserScreen({super.key});

  @override
  State<DashboardUserScreen> createState() => _DashboardUserScreenState();
}

class _DashboardUserScreenState extends State<DashboardUserScreen> {
  int _selectedIndex = 0;
  bool _isInit = false;

  final List<Widget> _pages = [
    HomeUserScreen(),
    const BookingScreen(),
    const RiwayatUserScreen(),
    const ProfileUserScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['tab'] is int) {
        _selectedIndex = args['tab'];
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false, // Pastikan background BottomNavigationBar menutup full
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false, // Hanya melindungi sisi bawah
        child: BottomNavigationBarWidgetUser(
          selectedIndex: _selectedIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
