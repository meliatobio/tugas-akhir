import 'package:bengkel/features/auth_owner/screens/login_owner_screen.dart';
import 'package:bengkel/features/auth_owner/screens/register_owner_screen.dart';
import 'package:bengkel/features/auth_user/screens/login_user_screen.dart';
import 'package:bengkel/features/auth_user/screens/register_user_screen.dart';
import 'package:bengkel/features/owner/screens/bengkel/manajemen_bengkel_screen.dart';
import 'package:bengkel/features/owner/screens/dashboard/dashboard_owner.dart';
import 'package:bengkel/features/owner/screens/profile/edit_profile_bengkel.dart';
import 'package:bengkel/features/owner/screens/profile/edit_profile_owner.dart';
import 'package:bengkel/features/owner/screens/profile/profile_owner.dart';
import 'package:bengkel/features/start/start_screen.dart';
import 'package:bengkel/features/user/screens/bengkel/detail_bengkel_screen.dart';
import 'package:bengkel/features/user/screens/booking/detail_booking_screen.dart';
import 'package:bengkel/features/user/screens/booking/input_booking_screen.dart';
import 'package:bengkel/features/user/screens/booking/transaksi_booking_screen.dart';
import 'package:bengkel/features/user/screens/dashboard/dashboard_user.dart';
import 'package:bengkel/features/user/screens/home/SearchBengkelScreen.dart';
import 'package:bengkel/features/user/screens/home/bengkel_terdekat_screen.dart';
import 'package:bengkel/features/user/screens/home/emergency.dart';
import 'package:bengkel/features/user/screens/home/home_user.dart';
import 'package:bengkel/features/user/screens/profile/edit_profile_user.dart';
import 'package:bengkel/features/user/screens/profile/profile_user.dart';

import 'package:bengkel/features/user/screens/riwayat/detail_transaksi_screen.dart';
import 'package:get/get.dart';

class Routers {
  static const start = '/start';
  static const loginuser = '/loginuser';
  static const loginowner = '/loginowner';
  static const registeruser = '/registeruser';
  static const registerowner = '/registerowner';
  static const dashboarduser = '/dashboarduser';
  static const dashboardowner = '/dashboardowner';
  static const home = '/home';
  static const emergency = '/emergency';
  static const detailtransaksi = '/detailtransaksi';
  static const bengkelterdekat = '/bengkelterdekat';
  static const detailbengkel = '/detailbengkel';
  static const inputbooking = '/inputbooking';
  static const transaksibooking = '/transaksibooking';
  static const detailbooking = '/detailbooking';
  static const profileuser = '/profileuser';
  static const profileowner = '/profileowner';
  static const editprofileowner = '/editprofileowner';
  static const editprofileuser = '/editprofileuser';
  static const String editprofilebengkel = '/edit-profile-bengkel';

  static const logout = '/logout';
  static const String searchbengkel = '/searchbengkel';
  static const String manajemenbengkel = '/manajemenbengkel';
  static final routes = [
    GetPage(name: start, page: () => StartScreen()),
    GetPage(name: loginuser, page: () => LoginUserScreen()),
    GetPage(name: loginowner, page: () => LoginOwnerScreen()),
    GetPage(name: registeruser, page: () => const RegisterUserScreen()),
    GetPage(name: registerowner, page: () => const RegisterOwnerScreen()),
    GetPage(name: dashboarduser, page: () => const DashboardUserScreen()),
    GetPage(name: dashboardowner, page: () => const DashboardOwnerScreen()),
    GetPage(name: home, page: () => const HomeUserScreen()),
    GetPage(name: emergency, page: () => const EmergencyScreen()),
    GetPage(
      name: detailtransaksi,
      page: () => const DetailTransaksiScreen(transaction: {}),
    ),
    GetPage(name: bengkelterdekat, page: () => const BengkelTerdekatScreen()),
    GetPage(name: detailbengkel, page: () => const DetailBengkelScreen()),
    GetPage(name: inputbooking, page: () => const InputBookingScreen()),
    GetPage(
      name: transaksibooking,
      page: () => TransaksiBookingScreen(transaction: Get.arguments),
    ),
    GetPage(
      name: detailbooking,
      page: () => DetailBookingScreen(transaction: Get.arguments),
    ),
    GetPage(name: profileuser, page: () => const ProfileUserScreen()),
    GetPage(name: profileowner, page: () => const ProfileOwnerScreen()),
    GetPage(
      name: editprofileowner,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return EditProfileOwnerScreen(user: args['user'], store: args['store']);
      },
    ),
    GetPage(name: editprofileuser, page: () => const EditProfileUserScreen()),
    GetPage(
      name: Routers.editprofilebengkel,
      page: () => EditProfileBengkelScreen(store: Get.arguments['store']),
    ),

    GetPage(name: logout, page: () => StartScreen()),
    GetPage(name: searchbengkel, page: () => SearchBengkelScreen()),
    GetPage(
      name: manajemenbengkel,
      page: () => ManajemenBengkelScreen(store: Get.arguments),
    ),
  ];
}
