import 'package:bengkel/features/auth/login_screen.dart';
import 'package:bengkel/features/auth/lupa_password_screen.dart';
import 'package:bengkel/features/auth/register_role.dart';
import 'package:bengkel/features/auth_owner/screens/register_owner_screen.dart';
import 'package:bengkel/features/auth_user/screens/register_user_screen.dart';
import 'package:bengkel/features/owner/screens/bengkel/manajemen_bengkel_screen.dart';
import 'package:bengkel/features/owner/screens/dashboard/dashboard_owner.dart';
import 'package:bengkel/features/owner/screens/home/tambah_bengkel_screen.dart';
import 'package:bengkel/features/owner/screens/profile/profile_owner.dart';
import 'package:bengkel/features/owner/screens/riwayat/detail_kelola_screen.dart';
import 'package:bengkel/features/owner/screens/riwayat/kelola_booking.dart';
import 'package:bengkel/features/splash/splash_screen.dart';
import 'package:bengkel/features/user/screens/bengkel/detail_bengkel_screen.dart';
import 'package:bengkel/features/user/screens/booking/input_booking_screen.dart';
import 'package:bengkel/features/user/screens/booking/transaksi_booking_screen.dart';
import 'package:bengkel/features/user/screens/dashboard/dashboard_user.dart';
import 'package:bengkel/features/user/screens/home/daftar_bengkel_screen.dart';
import 'package:bengkel/features/user/screens/home/emergency.dart';
import 'package:bengkel/features/user/screens/home/home_user.dart';
import 'package:bengkel/features/user/screens/home/search_bengkel_screen.dart';
import 'package:bengkel/features/user/screens/profile/edit_profile_user.dart';
import 'package:bengkel/features/user/screens/profile/profile_user.dart';
import 'package:bengkel/features/user/screens/riwayat/detail_transaksi_screen.dart';
import 'package:bengkel/models/booking_model.dart';
import 'package:get/get.dart';

class Routers {
  //auth
  static const splash = '/splash';
  static const login = '/login';
  static const registerrole = '/registerrole';
  static const String lupapassword = '/lupapassword';

  // user
  static const registeruser = '/registeruser';
  static const dashboarduser = '/dashboarduser';
  static const home = '/home';
  static const profileuser = '/profileuser';
  static const editprofileuser = '/editprofileuser';
  static const registerowner = '/registerowner';
  static const String searchbengkel = '/searchbengkel';
  static const emergency = '/emergency';
  static const detailtransaksi = '/detailtransaksi';
  static const daftarbengkel = '/daftarbengkel';
  static const detailbengkel = '/detailbengkel';
  static const inputbooking = '/inputbooking';
  static const transaksibooking = '/transaksibooking';
  static const detailbookinguser = '/detailbookinguser';

  // owner
  static const dashboardowner = '/dashboardowner';
  static const profileowner = '/profileowner';
  static const String manajemenbengkel = '/manajemenbengkel';
  static const String tambahbengkel = '/tambahbengkel';
  static const String detailtransaksiowner = '/detailtransaksiowner';
  static const String kelolabooking = '/kelolabooking';
  static const String detailbookingowner = '/detailbookingowner';

  static final routes = [
    // auth
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: registerrole, page: () => const RegisterRoleScreen()),
    GetPage(name: lupapassword, page: () => LupaPasswordScreen()),

    // user
    GetPage(name: dashboarduser, page: () => const DashboardUserScreen()),
    GetPage(name: registeruser, page: () => const RegisterUserScreen()),
    GetPage(name: home, page: () => const HomeUserScreen()),
    GetPage(name: emergency, page: () => const EmergencyScreen()),
    GetPage(name: profileuser, page: () => const ProfileUserScreen()),
    GetPage(name: editprofileuser, page: () => const EditProfileUserScreen()),
    GetPage(
      name: transaksibooking,
      page: () => TransaksiBookingScreen(transaction: Get.arguments),
    ),
    GetPage(
      name: Routers.searchbengkel,
      page: () => const SearchBengkelScreen(),
      transition: Transition.fadeIn, // biar list fade-in
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: detailtransaksi,
      page: () {
        final args =
            Get.arguments
                as Map<String, dynamic>?; // ambil argument dari Get.toNamed
        final bookingId = args?['bookingId'] as int?;
        if (bookingId == null) {
          throw Exception('Booking ID tidak ditemukan!');
        }
        return DetailTransaksiScreen(
          bookingId: bookingId,
          onBackToRiwayat: args?['onBackToRiwayat'] as void Function()?,
        );
      },
    ),

    GetPage(name: daftarbengkel, page: () => const DaftarBengkelScreen()),
    GetPage(name: detailbengkel, page: () => const DetailBengkelScreen()),
    GetPage(name: inputbooking, page: () => const InputBookingScreen()),

    //  owner
    GetPage(name: registerowner, page: () => const RegisterOwnerScreen()),
    GetPage(name: dashboardowner, page: () => const DashboardOwnerScreen()),

    GetPage(name: profileowner, page: () => const ProfileOwnerScreen()),

    GetPage(name: kelolabooking, page: () => const KelolaBookingScreen()),
    GetPage(
      name: '/detailbookingowner',
      page: () =>
          DetailKelolaScreen(transaction: Get.arguments as BookingModel),
    ),

    GetPage(
      name: '/manajemen-bengkel',
      page: () => ManajemenBengkelScreen(
        store: Get.arguments['store'],
        allStores: Get.arguments['allStores'],
      ),
    ),

    GetPage(name: tambahbengkel, page: () => TambahBengkelScreen()),
  ];
}
