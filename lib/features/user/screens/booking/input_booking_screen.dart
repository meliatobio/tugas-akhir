import 'package:bengkel/features/user/screens/booking/transaksi_booking_screen.dart';
import 'package:bengkel/services/storage_service.dart';
import 'package:bengkel/models/service_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputBookingScreen extends StatefulWidget {
  const InputBookingScreen({super.key});

  @override
  State<InputBookingScreen> createState() => _InputBookingScreenState();
}

class _InputBookingScreenState extends State<InputBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  int? selectedServiceId;
  String? selectedVehicleType;
  final licensePlateController = TextEditingController();
  DateTime? bookingDateTime;
  final notesController = TextEditingController();
  String paymentMethod = 'cash';
  late String openAt;
  late String closeAt;
  late List<ServiceModel> layananList;
  late int storeId;
  bool isSubmitting = false;
  bool get isFormValid {
    return selectedServiceId != null &&
        selectedVehicleType != null &&
        licensePlateController.text.isNotEmpty &&
        bookingDateTime != null;
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    layananList = args['layananList'] ?? [];
    storeId = args['storeId'] ?? 0;
    openAt = args['openAt'] ?? "08:00";
    closeAt = args['closeAt'] ?? "17:00";
  }

  void submitBooking() {
    if (!_formKey.currentState!.validate()) return;

    if (bookingDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal dan waktu booking')),
      );
      return;
    }

    if (selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih layanan terlebih dahulu')),
      );
      return;
    }

    final selectedService = layananList.firstWhere(
      (s) => s.id == selectedServiceId,
    );

    final transaction = {
      "userId": StorageService.userId,
      "storeId": storeId,
      "serviceId": selectedServiceId,
      "jenisKendaraan": selectedVehicleType,
      "noPol": licensePlateController.text,
      "tanggal":
          "${bookingDateTime!.day}/${bookingDateTime!.month}/${bookingDateTime!.year}",
      "jam":
          "${bookingDateTime!.hour.toString().padLeft(2, '0')}:${bookingDateTime!.minute.toString().padLeft(2, '0')}",
      "bookingDateTime": bookingDateTime,
      "layanan": selectedService.name,
      "totalHarga": selectedService.price,
      "catatan": notesController.text,
      "paymentMethod": paymentMethod,
    };

    Get.to(() => TransaksiBookingScreen(transaction: transaction));
  }

  @override
  void dispose() {
    licensePlateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Widget buildFormCard(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Input Booking',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildFormCard(
                DropdownButtonFormField<int>(
                  value: selectedServiceId,
                  items: layananList.map((service) {
                    return DropdownMenuItem(
                      value: service.id,
                      child: Text("${service.name} - Rp ${service.price}"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedServiceId = val),
                  validator: (val) => val == null ? 'Pilih layanan' : null,
                  decoration: const InputDecoration(
                    labelText: 'Layanan',
                    border: InputBorder.none,
                  ),
                ),
              ),
              buildFormCard(
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  items: const [
                    DropdownMenuItem(value: 'motorcycle', child: Text('Motor')),
                    DropdownMenuItem(value: 'car', child: Text('Mobil')),
                  ],
                  onChanged: (val) => setState(() => selectedVehicleType = val),
                  validator: (val) =>
                      val == null ? 'Pilih tipe kendaraan' : null,
                  decoration: const InputDecoration(
                    labelText: 'Tipe Kendaraan',
                    border: InputBorder.none,
                  ),
                ),
              ),
              buildFormCard(
                TextFormField(
                  controller: licensePlateController,
                  decoration: const InputDecoration(
                    labelText: 'Plat Nomor',
                    border: InputBorder.none,
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Masukkan plat nomor' : null,
                ),
              ),
              buildFormCard(
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    bookingDateTime == null
                        ? 'Pilih Tanggal Booking'
                        : "${bookingDateTime!.day}/${bookingDateTime!.month}/${bookingDateTime!.year} "
                              "${bookingDateTime!.hour.toString().padLeft(2, '0')}:${bookingDateTime!.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: bookingDateTime == null
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        final selected = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );

                        final openParts = openAt.split(":");
                        final closeParts = closeAt.split(":");
                        final openDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          int.parse(openParts[0]),
                          int.parse(openParts[1]),
                        );
                        final closeDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          int.parse(closeParts[0]),
                          int.parse(closeParts[1]),
                        );

                        if (selected.isBefore(openDateTime) ||
                            selected.isAfter(closeDateTime)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Jam booking harus antara $openAt - $closeAt WIB",
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          bookingDateTime = selected;
                        });
                      }
                    }
                  },
                ),
              ),
              buildFormCard(
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    border: InputBorder.none,
                  ),
                ),
              ),
              buildFormCard(
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text('Transfer Bank'),
                    ),
                  ],
                  onChanged: (val) =>
                      setState(() => paymentMethod = val ?? 'cash'),
                  decoration: const InputDecoration(
                    labelText: 'Metode Pembayaran',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isFormValid && !isSubmitting
                      ? submitBooking
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: isFormValid ? Colors.amber : Colors.grey,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Kirim Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
