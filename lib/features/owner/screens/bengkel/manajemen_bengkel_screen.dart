import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/features/owner/screens/dashboard/dashboard_owner.dart';
import 'package:bengkel/features/owner/services/store_service.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class ManajemenBengkelScreen extends StatefulWidget {
  final StoreModel store;
  final List<StoreModel> allStores;

  const ManajemenBengkelScreen({
    super.key,
    required this.store,
    required this.allStores,
  });

  @override
  State<ManajemenBengkelScreen> createState() => _ManajemenBengkelScreenState();
}

class _ManajemenBengkelScreenState extends State<ManajemenBengkelScreen> {
  late StoreModel store;
  bool isEmergencyOn = false;
  bool isLoadingDetail = false;
  bool isStoreOpen = false;
  String selectedVehicleType = "motorcycle"; // default motor

  final box = GetStorage();
  final StoreService storeService = StoreService();

  @override
  void initState() {
    super.initState();
    store = widget.store;
    isEmergencyOn = store.emergencyCall;
    isStoreOpen = store.active;

    _loadStoreDetail();
  }

  Future<void> _loadStoreDetail([int? storeIdParam]) async {
    final storeIdToFetch = storeIdParam ?? store.id;
    setState(() => isLoadingDetail = true);

    try {
      final role = box.read('role');
      StoreModel? detail;
      if (role == 'store') {
        detail = await storeService.fetchOwnedStoreById(storeIdToFetch);
      } else {
        detail = await storeService.fetchStoreDetailById(storeIdToFetch);
      }

      if (detail != null) {
        setState(() {
          store = detail!;
          isEmergencyOn = store.emergencyCall;
          isStoreOpen = store.active;
        });
        box.write('last_store_state', detail.toJson());
      } else {
        _useInitialStore();
      }
    } catch (e) {
      _useInitialStore();
    } finally {
      setState(() => isLoadingDetail = false);
    }
  }

  void _useInitialStore() {
    setState(() {
      store = widget.store;
      isEmergencyOn = store.emergencyCall;
      isStoreOpen = store.active;
    });
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    bool isLoading = false;

    StoreModel? selectedStore = widget.store;

    Map<String, String> vehicleTypeMap(StoreModel store) {
      final types = <String>{...store.acceptedVehicleTypes, 'motor', 'car'};
      Map<String, String> map = {};
      if (types.contains('motor')) map['Motor'] = 'motor';
      if (types.contains('car')) map['Mobil'] = 'car';
      return map;
    }

    Map<String, String> currentVehicleMap = selectedStore != null
        ? vehicleTypeMap(selectedStore)
        : {'Motor': 'motor', 'Mobil': 'car'};
    String selectedVehicleLabel = currentVehicleMap.keys.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Tambah Layanan"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.allStores.isNotEmpty)
                    DropdownButton<int>(
                      value: selectedStore?.id,
                      isExpanded: true,
                      items: widget.allStores.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.storeName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        final storeValue = widget.allStores.firstWhere(
                          (s) => s.id == value,
                        );
                        setState(() {
                          selectedStore = storeValue;
                          currentVehicleMap = vehicleTypeMap(selectedStore!);
                          selectedVehicleLabel = currentVehicleMap.keys.first;
                        });
                      },
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nama Layanan",
                    ),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Deskripsi"),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Harga"),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (selectedStore == null) return;

                        final name = nameController.text.trim();
                        final desc = descController.text.trim();
                        final price =
                            double.tryParse(priceController.text.trim()) ?? 0;

                        if (name.isEmpty || price <= 0) {
                          Get.snackbar(
                            "Error",
                            "Nama dan harga layanan wajib diisi",
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        final selectedVehicleType =
                            currentVehicleMap[selectedVehicleLabel]!;

                        final newService = await storeService.addService(
                          storeId: selectedStore!.id,
                          name: name,
                          vehicleType:
                              selectedVehicleType, // ✅ langsung dari state
                          description: desc,
                          price: price,
                        );

                        if (newService != null) {
                          // 🔹 Update state halaman, bukan hanya dialog
                          final index = widget.allStores.indexWhere(
                            (s) => s.id == selectedStore!.id,
                          );
                          if (index != -1) {
                            final updatedStore = widget.allStores[index]
                                .copyWith(
                                  services: [
                                    ...(widget.allStores[index].services ?? []),
                                    newService,
                                  ],
                                );
                            widget.allStores[index] = updatedStore;

                            if (selectedStore!.id == store.id) {
                              setState(() {
                                store = updatedStore; // 🔹 force rebuild page
                              });
                            }
                          }

                          Navigator.pop(context);
                          Get.snackbar(
                            "Sukses",
                            "Layanan berhasil ditambahkan",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            "Gagal",
                            "Tidak dapat menambahkan layanan",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }

                        setState(() => isLoading = false);
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          store.image != null && store.image!.isNotEmpty
              ? Image.network(
                  "${ApiBase.imageUrl}${store.image!}", // <--- jangan lupa prefix
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 280,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.store,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                )
              : Container(
                  width: double.infinity,
                  height: 280,
                  color: Colors.grey[200],
                  child: const Icon(Icons.store, size: 50, color: Colors.grey),
                ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.black,
                    iconSize: 28,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(16),
                child: isLoadingDetail
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isStoreOpen
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: isStoreOpen
                                            ? Colors.green
                                            : Colors.red,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isStoreOpen
                                            ? "BENGKEL BUKA"
                                            : "BENGKEL TUTUP",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isStoreOpen
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch.adaptive(
                                    value: isStoreOpen,
                                    activeColor: Colors.green,
                                    inactiveThumbColor: Colors.red,
                                    onChanged: (value) async {
                                      try {
                                        final result = await storeService
                                            .toggleStoreActive(
                                              storeId: store.id,
                                            );
                                        setState(() {
                                          isStoreOpen = result;
                                          store = store.copyWith(
                                            active: result,
                                          );
                                        });
                                      } catch (e) {
                                        Get.snackbar(
                                          "Error",
                                          "Gagal ubah status buka/tutup",
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.call,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Emergency Call",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            isEmergencyOn
                                                ? "Aktif"
                                                : "Nonaktif",
                                            style: TextStyle(
                                              color: isEmergencyOn
                                                  ? Colors.green
                                                  : Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Switch.adaptive(
                                    value: isEmergencyOn,
                                    activeColor: Colors.red,
                                    onChanged: (value) async {
                                      setState(() => isEmergencyOn = value);
                                      final success = await storeService
                                          .toggleEmergencyCallService(
                                            storeId: store.id,
                                            newValue: value,
                                          );
                                      if (success) {
                                        setState(
                                          () => store = store.copyWith(
                                            emergencyCall: value,
                                          ),
                                        );
                                      } else {
                                        setState(() => isEmergencyOn = !value);
                                        Get.snackbar(
                                          "Error",
                                          "Gagal ubah status Emergency Call",
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Nama Bengkel
                          Center(
                            child: Text(
                              store.storeName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Info Bengkel Card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          store.address ??
                                              'Alamat tidak tersedia',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.blueGrey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Jam Operasional: ${store.openAt} - ${store.closeAt} WIB',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Kontak: ${store.contact ?? "-"} (${store.contactName ?? "-"})',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Kendaraan yang dilayani
                                  const Text(
                                    "Kendaraan yang dilayani:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    children: store.acceptedVehicleTypes.map((
                                      type,
                                    ) {
                                      return Chip(
                                        label: Text(
                                          type == "car"
                                              ? "Mobil"
                                              : type == "motor"
                                              ? "Motor"
                                              : type,
                                        ),
                                        avatar: Icon(
                                          type == "car"
                                              ? Icons.directions_car
                                              : Icons.motorcycle,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        backgroundColor: Colors.amber,
                                        labelStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                final lat = store.lat; // ambil dari model
                                final lng = store.long;

                                if (lat != null && lng != null) {
                                  final url = Uri.parse(
                                    "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
                                  );
                                  launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  Get.snackbar(
                                    "Lokasi tidak tersedia",
                                    "Data latitude/longitude bengkel belum ada",
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/map_placeholder.png',
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    height: 150,
                                    color: Colors.black26,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "Lihat Lokasi",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Section Header
                          Row(
                            children: const [
                              Icon(Icons.build, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'Layanan Aktif',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Divider(thickness: 1.2),

                          // Daftar Layanan
                          (store.services?.isEmpty ?? true)
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    "Belum ada layanan terdaftar.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : Column(
                                  children: store.services!.map((service) {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 1,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                        title: Text(
                                          service.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(service.description),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Rp ${service.price.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            // 🔹 Icon edit
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.black,
                                              ),
                                              onPressed: () {
                                                final nameController =
                                                    TextEditingController(
                                                      text: service.name,
                                                    );
                                                final descController =
                                                    TextEditingController(
                                                      text: service.description,
                                                    );
                                                final priceController =
                                                    TextEditingController(
                                                      text: service.price
                                                          .toString(),
                                                    );

                                                Get.defaultDialog(
                                                  title: "Edit Layanan",
                                                  content: Column(
                                                    children: [
                                                      TextField(
                                                        controller:
                                                            nameController,
                                                        decoration:
                                                            const InputDecoration(
                                                              labelText:
                                                                  "Nama Layanan",
                                                            ),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            descController,
                                                        decoration:
                                                            const InputDecoration(
                                                              labelText:
                                                                  "Deskripsi",
                                                            ),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            priceController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            const InputDecoration(
                                                              labelText:
                                                                  "Harga",
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  textCancel: "Batal",
                                                  textConfirm: "Simpan",
                                                  confirmTextColor:
                                                      Colors.white,
                                                  onConfirm: () async {
                                                    Get.back();
                                                    final updatedService =
                                                        await storeService
                                                            .updateService(
                                                              service.id,
                                                              name:
                                                                  nameController
                                                                      .text,
                                                              description:
                                                                  descController
                                                                      .text,
                                                              price:
                                                                  double.tryParse(
                                                                    priceController
                                                                        .text,
                                                                  ) ??
                                                                  service.price
                                                                      .toDouble(),
                                                            );
                                                    if (updatedService !=
                                                        null) {
                                                      setState(() {
                                                        final index = store
                                                            .services
                                                            .indexWhere(
                                                              (s) =>
                                                                  s.id ==
                                                                  service.id,
                                                            );
                                                        store.services![index] =
                                                            updatedService;
                                                      });
                                                      Get.snackbar(
                                                        "Sukses",
                                                        "Layanan berhasil diupdate",
                                                        backgroundColor:
                                                            Colors.green,
                                                        colorText: Colors.white,
                                                      );
                                                    } else {
                                                      Get.snackbar(
                                                        "Gagal",
                                                        "Tidak dapat mengupdate layanan",
                                                        backgroundColor:
                                                            Colors.red,
                                                        colorText: Colors.white,
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                            // 🔹 Icon delete
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                Get.defaultDialog(
                                                  title: "Konfirmasi",
                                                  middleText:
                                                      "Hapus layanan '${service.name}'?",
                                                  textCancel: "Batal",
                                                  textConfirm: "Hapus",
                                                  confirmTextColor:
                                                      Colors.white,
                                                  onConfirm: () async {
                                                    Get.back();
                                                    final success =
                                                        await storeService
                                                            .deleteService(
                                                              service.id,
                                                            );
                                                    if (success) {
                                                      setState(() {
                                                        store.services!
                                                            .removeWhere(
                                                              (s) =>
                                                                  s.id ==
                                                                  service.id,
                                                            );
                                                      });
                                                      Get.snackbar(
                                                        "Sukses",
                                                        "Layanan berhasil dihapus",
                                                        backgroundColor:
                                                            Colors.green,
                                                        colorText: Colors.white,
                                                      );
                                                    } else {
                                                      Get.snackbar(
                                                        "Gagal",
                                                        "Tidak dapat menghapus layanan",
                                                        backgroundColor:
                                                            Colors.red,
                                                        colorText: Colors.white,
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                          const SizedBox(height: 12),

                          // Tombol Tambah Layanan
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showAddServiceDialog,
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.white,
                              ),
                              label: const Text('Tambah Layanan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor:
                                    Colors.black, // 🔹 teks tombol jadi hitam
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Icon(Icons.forum, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'Ulasan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          const Divider(),
                          (store.reviews?.isEmpty ?? true)
                              ? const Text("Belum ada ulasan.")
                              : Column(
                                  children: store.reviews!.map((review) {
                                    return Card(
                                      child: ListTile(
                                        title: Text(
                                          review.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: List.generate(5, (
                                                index,
                                              ) {
                                                final fullStars = review.rating
                                                    .floor();
                                                final hasHalfStar =
                                                    (review.rating -
                                                        fullStars) >=
                                                    0.5;
                                                if (index < fullStars) {
                                                  return const Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  );
                                                } else if (index == fullStars &&
                                                    hasHalfStar) {
                                                  return const Icon(
                                                    Icons.star_half,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  );
                                                } else {
                                                  return const Icon(
                                                    Icons.star_border,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  );
                                                }
                                              }),
                                            ),
                                            const SizedBox(height: 4),
                                            Text('"${review.comment}"'),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                          //
                          // Tombol Hapus Bengkel
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Dialog konfirmasi
                                Get.defaultDialog(
                                  title: "Konfirmasi",
                                  middleText:
                                      "Apakah kamu yakin ingin menghapus bengkel?",
                                  textCancel: "Tidak",
                                  textConfirm: "Ya",
                                  confirmTextColor: Colors.white,
                                  onConfirm: () async {
                                    Get.back(); // tutup dialog
                                    try {
                                      final success = await storeService
                                          .deleteStore(store.id);
                                      if (success) {
                                        Get.snackbar(
                                          "Sukses",
                                          "Bengkel berhasil dihapus",
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                        );

                                        // ✅ Arahkan ke DashboardOwnerScreen dengan tab Home aktif
                                        Get.offAll(
                                          () => const DashboardOwnerScreen(),
                                          arguments: 0,
                                        );
                                      } else {
                                        Get.snackbar(
                                          "Gagal",
                                          "Tidak dapat menghapus bengkel",
                                          backgroundColor: Colors.redAccent,
                                          colorText: Colors.white,
                                        );
                                      }
                                    } catch (e) {
                                      Get.snackbar(
                                        "Error",
                                        "Terjadi kesalahan",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                                size: 22,
                              ),
                              label: const Text(
                                "Hapus Bengkel",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
