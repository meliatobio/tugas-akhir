class ApiBase {
  static const baseUrl = 'http://localhost:8000/api/';

  static Uri uri(String endpoint) {
    return Uri.parse('$baseUrl$endpoint');
  }
}
