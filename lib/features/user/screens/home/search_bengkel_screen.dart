import 'dart:async';
import 'dart:convert';
import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class SearchBengkelScreen extends StatefulWidget {
  const SearchBengkelScreen({super.key});

  @override
  State<SearchBengkelScreen> createState() => _SearchBengkelScreenState();
}

class _SearchBengkelScreenState extends State<SearchBengkelScreen> {
  List<StoreModel> searchResults = [];
  Timer? _debounce;

  final TextEditingController _searchController = TextEditingController();
  final box = GetStorage();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllStores();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAllStores() async {
    final token = box.read('token');
    final url = Uri.parse('${ApiBase.baseUrl}store');

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data'];

        setState(() {
          searchResults = data.map((e) => StoreModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          searchResults = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error saat fetch all stores: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> searchStore(String keyword) async {
    final token = box.read('token');
    final url = Uri.parse('${ApiBase.baseUrl}store');

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data'];

        // Filter secara lokal di Flutter
        final filtered = data.where((e) {
          final name = (e['store_name'] as String).toLowerCase();
          return name.startsWith(keyword.toLowerCase());
        }).toList();

        setState(() {
          searchResults = filtered.map((e) => StoreModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          searchResults = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error saat search: $e");
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        fetchAllStores();
      } else {
        searchStore(query.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Bengkel"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Cari nama bengkel...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final store = searchResults[index];
                      return ListTile(
                        title: Text(store.storeName),
                        subtitle: Text(
                          store.address ?? 'Alamat tidak tersedia',
                        ), // ✅ FIX
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.toNamed(
                            Routers.detailbengkel,
                            arguments: store.id,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
