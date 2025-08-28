import 'package:bengkel/models/booking_model.dart';
import 'package:bengkel/services/booking_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

class DetailKelolaScreen extends StatefulWidget {
  final BookingModel transaction; // required

  const DetailKelolaScreen({Key? key, required this.transaction})
    : super(key: key);

  @override
  State<DetailKelolaScreen> createState() => _DetailKelolaScreenState();
}

class _DetailKelolaScreenState extends State<DetailKelolaScreen> {
  late String selectedStatus;
  final screenshotController = ScreenshotController();
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.transaction.status;
  }

  // ===================== JPG =====================
  Future<void> _downloadJpg() async {
    setState(() => isDownloading = true);
    try {
      Uint8List? raw = await screenshotController.capture();
      if (raw == null) throw Exception("Gagal capture screenshot");

      final decoded = img.decodeImage(raw);
      if (decoded == null) throw Exception("Decode image gagal");

      const padding = 32;
      final whiteBg = img.Image(
        width: decoded.width + (padding * 2),
        height: decoded.height + (padding * 2),
      );

      img.fill(whiteBg, color: img.ColorRgb8(255, 255, 255));
      img.compositeImage(whiteBg, decoded, dstX: padding, dstY: padding);

      Uint8List jpg = Uint8List.fromList(img.encodeJpg(whiteBg));

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/kelola_${widget.transaction.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final file = File(filePath);
      await file.writeAsBytes(jpg);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Download JPG selesai')));
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint('Download JPG error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Gagal download JPG')));
    } finally {
      setState(() => isDownloading = false);
    }
  }

  // ===================== PDF =====================
  Future<void> _downloadPdfFromData() async {
    setState(() => isDownloading = true);
    try {
      final pdf = pw.Document();

      // Load logo
      final logoBytes = (await rootBundle.load(
        'assets/images/logo.png',
      )).buffer.asUint8List();
      final logoImage = pw.MemoryImage(logoBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header dengan judul & logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Detail Booking",
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

                // Status & Tanggal
                pw.Text(
                  "Status: ${widget.transaction.status}",
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  "Tanggal: ${widget.transaction.bookingDate} ${widget.transaction.bookingTime}",
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 12),

                // Tabel detail
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FlexColumnWidth(6),
                  },
                  children: [
                    _buildTableRow("Username", widget.transaction.username),
                    _buildTableRow(
                      "Jenis Kendaraan",
                      widget.transaction.vehicleType,
                    ),
                    _buildTableRow(
                      "No Polisi",
                      widget.transaction.licensePlate,
                    ),
                    _buildTableRow("Layanan", widget.transaction.serviceName),

                    _buildTableRow(
                      "Total Harga",
                      formatCurrency(widget.transaction.totalPrice),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Footer
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
          '${dir.path}/kelola_${widget.transaction.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Download PDF selesai')));
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint('Download PDF error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Gagal download PDF')));
    } finally {
      setState(() => isDownloading = false);
    }
  }

  // ===================== Excel =====================
  Future<void> _downloadExcel() async {
    final tx = widget.transaction;

    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Header
    sheet.appendRow([TextCellValue("Field"), TextCellValue("Value")]);

    // Data
    sheet.appendRow([TextCellValue("Status"), TextCellValue(tx.status)]);
    sheet.appendRow([
      TextCellValue("Jenis Kendaraan"),
      TextCellValue(tx.vehicleType),
    ]);
    sheet.appendRow([
      TextCellValue("Tanggal"),
      TextCellValue("${tx.bookingDate} ${tx.bookingTime}"),
    ]);
    sheet.appendRow([
      TextCellValue("No Polisi"),
      TextCellValue(tx.licensePlate),
    ]);
    sheet.appendRow([TextCellValue("Layanan"), TextCellValue(tx.serviceName)]);
    sheet.appendRow([
      TextCellValue("Total Harga"),
      TextCellValue(formatCurrency(tx.totalPrice)),
    ]);

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/report_${tx.id}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Download Excel selesai ✅')));
      await OpenFile.open(filePath);
    }
  }

  // ===================== Update Status =====================
  Future<void> updateStatus() async {
    final success = await BookingService.updateBookingStatus(
      bookingId: widget.transaction.id,
      status: selectedStatus,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Status berhasil diubah ke $selectedStatus"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  // ===================== Format Currency =====================
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return formatter.format(amount);
  }

  // ===================== Show Download Options =====================
  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("Unduh sebagai PDF"),
              onTap: () {
                Navigator.pop(context);
                _downloadPdfFromData(); // pakai metode data langsung
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text("Unduh sebagai JPG"),
              onTap: () {
                Navigator.pop(context);
                _downloadJpg();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text("Unduh sebagai Excel"),
              onTap: () {
                Navigator.pop(context);
                _downloadExcel();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Build Screen =====================
  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Detail Booking",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, size: 22, color: Colors.amber),
                          const SizedBox(width: 12),
                          const Expanded(
                            flex: 3,
                            child: Text(
                              "Status",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: DropdownButtonFormField<String>(
                              value: selectedStatus,
                              items: const [
                                DropdownMenuItem(
                                  value: "pending",
                                  child: Text("Pending"),
                                ),
                                DropdownMenuItem(
                                  value: "confirmed",
                                  child: Text("Confirmed"),
                                ),
                                DropdownMenuItem(
                                  value: "completed",
                                  child: Text("Completed"),
                                ),
                                DropdownMenuItem(
                                  value: "cancelled",
                                  child: Text("Cancelled"),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedStatus = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildDetailItem(Icons.person, "Username", tx.username),
                      _buildDetailItem(
                        Icons.directions_car,
                        "Jenis Kendaraan",
                        tx.vehicleType,
                      ),
                      _buildDetailItem(
                        Icons.calendar_today,
                        "Tanggal",
                        "${tx.bookingDate} ${tx.bookingTime}",
                      ),
                      _buildDetailItem(
                        Icons.confirmation_number,
                        "No Polisi",
                        tx.licensePlate,
                      ),
                      _buildDetailItem(Icons.build, "Layanan", tx.serviceName),
                      _buildDetailItem(
                        Icons.monetization_on,
                        "Total Harga",
                        formatCurrency(tx.totalPrice),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.save),
              label: const Text(
                "Simpan Perubahan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: updateStatus,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.download),
              label: const Text("Unduh"),
              onPressed: _showDownloadOptions,
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Detail Item Builder =====================
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.amber[800]),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Table Row Helper =====================
  pw.TableRow _buildTableRow(String label, String? value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value ?? '-'),
        ),
      ],
    );
  }
}
