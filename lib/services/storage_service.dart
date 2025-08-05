import 'package:get_storage/get_storage.dart';

class StorageService {
  static final _box = GetStorage();

  // Ambil token
  static String? get token => _box.read('token');

  // Simpan token
  static set token(String? value) => _box.write('token', value);

  // Hapus semua data (untuk logout, dll)
  static void clear() => _box.erase();
}
