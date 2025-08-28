import 'package:get_storage/get_storage.dart';

class StorageService {
  static final _box = GetStorage();
  static String? get token => _box.read('token');
  static String? userName;
  static set token(String? value) => _box.write('token', value);
  static int? get userId => _box.read('user_id');
  static set userId(int? value) => _box.write('user_id', value);

  // Hapus semua data
  static void clear() => _box.erase();
}
