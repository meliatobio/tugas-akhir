// class ApiBase {
//   static const String baseUrl = "http://127.0.0.1:8000";
//   static const String apiUrl = "$baseUrl/api/";
//   static const String imageUrl = "$baseUrl/store_photos/";
//   static Uri uri(String endpoint) {
//     return Uri.parse('$baseUrl$endpoint');
//   }
// }

class ApiBase {
  static const baseUrl = 'http://10.24.122.141:8000/api/';
  static const String imageUrl = "http://10.24.122.141:8000/";
  static Uri uri(String endpoint) {
    return Uri.parse('$baseUrl$endpoint');
  }
}
