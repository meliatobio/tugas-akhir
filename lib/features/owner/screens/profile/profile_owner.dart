import 'dart:convert';
import 'package:bengkel/app/routers.dart';
import 'package:bengkel/features/owner/services/store_service.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:bengkel/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileOwnerScreen extends StatefulWidget {
  const ProfileOwnerScreen({super.key});

  @override
  State<ProfileOwnerScreen> createState() => _ProfileOwnerScreenState();
}

class _ProfileOwnerScreenState extends State<ProfileOwnerScreen> {
  final storeService = StoreService();

  late UserModel user;
  String token = '';
  bool isLoading = true;
  List<StoreModel> localStoreList = [];
  List<StoreModel> stores = [];
  List<bool> isStoreLoading = []; // untuk per store (edit simpan)
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> addressControllers = [];
  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> contactNameControllers = [];
  List<TextEditingController> openAtControllers = [];
  List<TextEditingController> closeAtControllers = [];
  List<TextEditingController> latControllers = [];
  List<TextEditingController> longControllers = [];
  List<List<String>> selectedVehicleTypes = []; // untuk kendaraan mobil/motor

  List<bool> isEditing = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final box = GetStorage();

    final dynamic userRaw = box.read('user');
    final savedToken = box.read('token') ?? '';
    this.token = savedToken;

    Map<String, dynamic> userMap = {};
    if (userRaw is Map<String, dynamic>) {
      userMap = userRaw;
    } else if (userRaw is String) {
      try {
        userMap = jsonDecode(userRaw);
      } catch (e) {
        debugPrint("❌ Gagal decode user dari string: $e");
      }
    }

    user = UserModel.fromJson(userMap);
    await _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      final fetchedStores = await storeService.getAllOwnedStores(token);

      setState(() {
        localStoreList = fetchedStores;
        isStoreLoading = List.filled(
          localStoreList.length,
          false,
        ); // <- tambahkan ini
        nameControllers = [];
        addressControllers = [];
        phoneControllers = [];

        isEditing = [];

        for (var store in localStoreList) {
          nameControllers.add(TextEditingController(text: store.storeName));
          addressControllers.add(
            TextEditingController(text: store.address ?? ''),
          );
          phoneControllers.add(
            TextEditingController(text: store.contact ?? ''),
          );
          contactNameControllers.add(
            TextEditingController(text: store.contactName ?? ''),
          );
          openAtControllers.add(
            TextEditingController(text: store.openAt ?? ''),
          );
          closeAtControllers.add(
            TextEditingController(text: store.closeAt ?? ''),
          );
          latControllers.add(
            TextEditingController(text: store.lat?.toString() ?? ''),
          );
          longControllers.add(
            TextEditingController(text: store.long?.toString() ?? ''),
          );
          selectedVehicleTypes.add(
            List<String>.from(store.acceptedVehicleTypes),
          );

          isEditing.add(false);
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading store data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Data Pemilik'),
              Tab(text: 'Data Bengkel'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(children: [_buildOwnerTab(), _buildWorkshopTab()]),
      ),
    );
  }

  Widget _buildOwnerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFD9D9D9),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            'Hi, ${user.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Data Pemilik",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileField('Nama', user.name),
          _buildProfileField('Email', user.email),
          _buildProfileField('Alamat', user.address),
          _buildProfileField(
            'No. Telepon',
            user.phone.isNotEmpty ? user.phone : '-',
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(
                Routers.editprofileowner,
                arguments: {'user': user, 'token': token},
              );
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Data Pemilik'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Konfirmasi Logout"),
                  content: const Text("Apakah kamu yakin ingin logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        GetStorage().erase();
                        Navigator.of(context).pop();
                        Get.offAllNamed(Routers.start);
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Bengkel Anda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...localStoreList.asMap().entries.map((entry) {
            int index = entry.key;
            final store = entry.value;

            final isEditMode = isEditing[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.storeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isEditMode
                        ? Column(
                            children: [
                              _buildTextField(
                                'Nama Bengkel',
                                nameControllers[index],
                              ),
                              _buildTextField(
                                'Alamat',
                                addressControllers[index],
                              ),
                              _buildTextField(
                                'Kontak',
                                phoneControllers[index],
                              ),
                              _buildTextField(
                                'Nama Kontak',
                                contactNameControllers[index],
                              ),
                              _buildTextField(
                                'Jam Buka (HH:mm)',
                                openAtControllers[index],
                              ),
                              _buildTextField(
                                'Jam Tutup (HH:mm)',
                                closeAtControllers[index],
                              ),
                              _buildTextField(
                                'Latitude',
                                latControllers[index],
                              ),
                              _buildTextField(
                                'Longitude',
                                longControllers[index],
                              ),

                              // Dropdown Checkbox Kendaraan
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Jenis Kendaraan yang Dilayani',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8.0,
                                      children: ['mobil', 'motor'].map((type) {
                                        final isSelected =
                                            selectedVehicleTypes[index]
                                                .contains(type);
                                        return FilterChip(
                                          label: Text(type),
                                          selected: isSelected,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              if (selected) {
                                                selectedVehicleTypes[index].add(
                                                  type,
                                                );
                                              } else {
                                                selectedVehicleTypes[index]
                                                    .remove(type);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: isStoreLoading[index]
                                    ? null
                                    : () async {
                                        setState(() {
                                          isStoreLoading[index] = true;
                                        });

                                        final isSuccess = await storeService
                                            .updateStoreProfile(
                                              storeId: store.id,
                                              storeName:
                                                  nameControllers[index].text,
                                              address: addressControllers[index]
                                                  .text,
                                              contact:
                                                  phoneControllers[index].text,
                                              contactName:
                                                  contactNameControllers[index]
                                                      .text,
                                              lat:
                                                  double.tryParse(
                                                    latControllers[index].text,
                                                  ) ??
                                                  0.0,
                                              long:
                                                  double.tryParse(
                                                    longControllers[index].text,
                                                  ) ??
                                                  0.0,
                                              openAt:
                                                  openAtControllers[index].text,
                                              closeAt: closeAtControllers[index]
                                                  .text,
                                              acceptedVehicleTypes:
                                                  selectedVehicleTypes[index],
                                              image:
                                                  null, // Tambahkan jika ingin upload gambar
                                            );

                                        setState(() {
                                          isStoreLoading[index] = false;
                                        });

                                        if (isSuccess) {
                                          setState(() {
                                            localStoreList[index] = store.copyWith(
                                              storeName:
                                                  nameControllers[index].text,
                                              address: addressControllers[index]
                                                  .text,
                                              contact:
                                                  phoneControllers[index].text,
                                              contactName:
                                                  contactNameControllers[index]
                                                      .text,
                                              openAt:
                                                  openAtControllers[index].text,
                                              closeAt: closeAtControllers[index]
                                                  .text,
                                              lat: double.tryParse(
                                                latControllers[index].text,
                                              ),
                                              long: double.tryParse(
                                                longControllers[index].text,
                                              ),
                                              acceptedVehicleTypes:
                                                  selectedVehicleTypes[index],
                                            );
                                            isEditing[index] = false;
                                          });

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '✅ Bengkel berhasil diperbarui',
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '❌ Gagal memperbarui data bengkel',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                child: isStoreLoading[index]
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Simpan'),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileField(
                                'Nama Bengkel',
                                store.storeName,
                              ),
                              _buildProfileField(
                                'Alamat',
                                store.address ?? '-',
                              ),
                              _buildProfileField(
                                'Kontak',
                                store.contact ?? '-',
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      isEditing[index] = true;
                                    });
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Edit"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProfileField(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
