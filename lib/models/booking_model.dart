// lib/features/booking/models/booking_model.dart

class BookingModel {
  final String id;
  final String status;
  final String bookingDate;
  final String bookingTime;
  final String vehicleType;
  final String licensePlate;
  final String serviceName;
  final int dpAmount;
  final int totalPrice;
  final String bankAccount;

  BookingModel({
    required this.id,
    required this.status,
    required this.bookingDate,
    required this.bookingTime,
    required this.vehicleType,
    required this.licensePlate,
    required this.serviceName,
    required this.dpAmount,
    required this.totalPrice,
    required this.bankAccount,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'].toString(),
      status: json['status'] ?? 'Menunggu',
      bookingDate: json['booking_time']?.split('T')?.first ?? '',
      bookingTime:
          json['booking_time']?.split('T')?.last?.substring(0, 5) ?? '',
      vehicleType: json['vehicle_type'] ?? 'Motor',
      licensePlate: json['license_plate'] ?? '-',
      serviceName: json['service_name'] ?? '-',
      dpAmount: (json['dp_amount'] ?? 0) as int,
      totalPrice: (json['total_price'] ?? 0) as int,
      bankAccount: json['bank_account'] ?? 'Belum tersedia',
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "status": status,
    "tanggal": bookingDate,
    "jam": bookingTime,
    "jenisKendaraan": vehicleType,
    "noPol": licensePlate,
    "layanan": serviceName,
    "dp": dpAmount,
    "totalHarga": totalPrice,
    "rekening": bankAccount,
  };
}
