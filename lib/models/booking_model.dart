class BookingModel {
  final int id;
  final String status;
  final String bookingDate;
  final String bookingTime;
  final String vehicleType;
  final String licensePlate;
  final String serviceName;
  final int dpAmount;
  final double totalPrice;
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
    final String fullTime = json['booking_time'] ?? '';
    final split = fullTime.split('T');
    final date = split.isNotEmpty ? split.first : '';
    final time = split.length > 1 ? split.last.substring(0, 5) : '';

    return BookingModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      status: json['status'] ?? 'Menunggu',
      bookingDate: date,
      bookingTime: time,
      vehicleType: json['vehicle_type'] ?? '-',
      licensePlate: json['license_plate'] ?? '-',
      serviceName: json['service_name'] ?? '-',
      dpAmount: json['dp_amount'] ?? 0,
      totalPrice: (json['total_price'] != null)
          ? double.tryParse(json['total_price'].toString()) ?? 0.0
          : 0.0,
      bankAccount: json['bank_account'] ?? '-',
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
