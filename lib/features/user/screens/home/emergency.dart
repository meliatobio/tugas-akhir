import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  List<dynamic> _bengkels = [];
  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEmergencyBengkels();
  }

  Future<String> _getToken() async {
    return await _storage.read(key: 'token') ?? '';
  }

  Future<void> _fetchEmergencyBengkels() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      String token = await _getToken();
      if (token.isEmpty) {
        debugPrint("⚠️ Token kosong, tidak bisa fetch emergency bengkel.");
        setState(() {
          _errorMessage = 'Token belum tersedia, coba login ulang.';
        });
        return;
      }

      debugPrint("🔑 Token yang digunakan: $token");

      final response = await _dio.get(
        'https://your-api.com/api/emergency-bengkels',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Data emergency bengkel: ${response.data}");
        setState(() {
          _bengkels = response.data ?? [];
        });
      } else {
        debugPrint("❌ Gagal ambil data: ${response.statusCode}");
        setState(() {
          _errorMessage =
              'Error: ${response.statusCode} - ${response.statusMessage}';
        });
      }
    } catch (e) {
      debugPrint("🔥 Exception: $e");
      setState(() {
        _errorMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Bengkel')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : ListView.builder(
              itemCount: _bengkels.length,
              itemBuilder: (context, index) {
                final bengkel = _bengkels[index];
                return ListTile(
                  title: Text(bengkel['store_name'] ?? 'Tanpa Nama'),
                  subtitle: Text(bengkel['address'] ?? 'Tanpa Alamat'),
                );
              },
            ),
    );
  }
}
