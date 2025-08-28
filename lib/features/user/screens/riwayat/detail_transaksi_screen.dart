import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/widgets.dart' as pw;

class DetailTransaksiScreen extends StatefulWidget {
  final int bookingId;
  final void Function()? onBackToRiwayat;

  const DetailTransaksiScreen({
    Key? key,
    required this.bookingId,
    this.onBackToRiwayat,
  }) : super(key: key);

  @override
  State<DetailTransaksiScreen> createState() => _DetailTransaksiScreenState();
}

class _DetailTransaksiScreenState extends State<DetailTransaksiScreen> {
  Map<String, dynamic>? transaction;
  bool isLoading = true;
  bool isDownloading = false;

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _fetchTransaction();
  }

  Future<void> _fetchTransaction() async {
    final token = StorageService.token;
    try {
      final res = await http.get(
        Uri.parse('${ApiBase.baseUrl}booking/${widget.bookingId}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        setState(() {
          transaction = decoded['data'] ?? decoded;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal fetch booking: ${res.body}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetch booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat fetch booking')),
      );
    }
  }

  // DOWNLOAD JPG MENGGUNAKAN SCREENSHOT
  Future<void> _downloadJpg() async {
    setState(() => isDownloading = true);
    try {
      Uint8List? raw = await screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );
      if (raw == null) throw Exception("Gagal capture screenshot");

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/report_${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final file = File(filePath);
      await file.writeAsBytes(raw);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Download JPG selesai')));

      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint('Download JPG error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal download JPG')));
    } finally {
      setState(() => isDownloading = false);
    }
  }

  Future<void> _downloadPdfFromData() async {
    setState(() => isDownloading = true);

    try {
      final pdf = pw.Document();

      // --- Load logo dulu sebelum addPage ---
      final logoBytes = (await rootBundle.load(
        'assets/images/logo.png',
      )).buffer.asUint8List();
      final logoImage = pw.MemoryImage(logoBytes);

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header dengan judul dan logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Detail Transaksi",
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Container(
                      width: 50,
                      height: 50,
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 12),

                // Status & Waktu
                pw.Text(
                  "Status: ${transaction?['status'] ?? '-'}",
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  "Waktu Booking: ${transaction?['booking_time'] ?? '-'}",
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 12),

                // Tabel informasi transaksi
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FlexColumnWidth(6),
                  },
                  children: [
                    _buildTableRow(
                      "Bengkel",
                      transaction?['store']?['store_name'],
                    ),
                    _buildTableRow(
                      "Jenis Kendaraan",
                      transaction?['vehicle_type'],
                    ),
                    _buildTableRow("No Polisi", transaction?['license_plate']),
                    _buildTableRow("Layanan", transaction?['service']?['name']),
                    _buildTableRow(
                      "Metode Pembayaran",
                      transaction?['payment_method'],
                    ),
                    _buildTableRow("Catatan", transaction?['notes']),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Total Harga
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  color: PdfColor.fromInt(0xFF4CAF50),
                  child: pw.Text(
                    "Total Harga: Rp${transaction?['total_price'] ?? 0}",
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),

                // Footer opsional
                pw.Center(
                  child: pw.Text(
                    "Terima kasih telah menggunakan layanan kami",
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/report_${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Download PDF selesai')));
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint('Download PDF error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal download PDF')));
    } finally {
      setState(() => isDownloading = false);
    }
  }

  // Helper untuk membangun row tabel
  pw.TableRow _buildTableRow(String label, dynamic value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: pw.Text(value?.toString() ?? '-'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Detail Transaksi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Screenshot(
                  controller: screenshotController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildStatusHeader(
                        transaction?['status'],
                        transaction?['booking_time'],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(
                        "Bengkel",
                        transaction?['store']?['store_name'] ?? 'Unknown',
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        "Jenis Kendaraan",
                        transaction?['vehicle_type'],
                      ),
                      _buildDivider(),
                      _buildInfoRow("No Polisi", transaction?['license_plate']),
                      _buildDivider(),
                      _buildInfoRow(
                        "Layanan",
                        transaction?['service']?['name'],
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        "Metode Pembayaran",
                        transaction?['payment_method'],
                      ),
                      _buildDivider(),
                      _buildInfoRow("Catatan", transaction?['notes'] ?? '-'),
                      const SizedBox(height: 32),
                      _buildTotalHarga(
                        "Total Harga",
                        "Rp${transaction?['total_price'] ?? 0}",
                      ),
                      const SizedBox(height: 16),
                      isDownloading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  context: context,
                                  builder: (_) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.redAccent,
                                        ),
                                        title: const Text("Download PDF"),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _downloadPdfFromData(); // gunakan PDF dari data
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.image,
                                          color: Colors.blueAccent,
                                        ),
                                        title: const Text("Download JPG"),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _downloadJpg(); // tetap dari screenshot
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.download,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Unduh",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.green,
                                elevation: 6,
                                shadowColor: Colors.green,
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Divider(thickness: 0.5, color: Colors.black26),
  );

  Widget _buildInfoRow(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          flex: 6,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value ?? '-',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    ),
  );

  Widget _buildTotalHarga(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStatusHeader(String? status, String? bookingTime) {
    Color bgColor;
    IconData iconData;

    switch (status?.toLowerCase()) {
      case 'pending':
        bgColor = Colors.orange;
        iconData = Icons.hourglass_empty;
        break;
      case 'completed':
        bgColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'cancelled':
        bgColor = Colors.red;
        iconData = Icons.cancel;
        break;
      case 'confirmed':
        bgColor = Colors.blue;
        iconData = Icons.verified;
        break;
      default:
        bgColor = Colors.grey;
        iconData = Icons.help;
    }

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: bgColor.withAlpha(52),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, size: 40, color: bgColor),
        ),
        const SizedBox(height: 12),
        Text(
          status?.toUpperCase() ?? '-',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: bgColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(bookingTime ?? '-', style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
