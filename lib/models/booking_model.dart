class BookingModel {
  final int id;
  String status; // bisa diubah
  final String username;
  final String bookingDate;
  final String bookingTime;
  final String vehicleType;
  final String licensePlate;
  final String serviceName;
  final int dpAmount;
  final double totalPrice;
  final String bankAccount;
  final int storeId;
  final String storeName;

  BookingModel({
    required this.id,
    required this.status,
    required this.username,
    required this.bookingDate,
    required this.bookingTime,
    required this.vehicleType,
    required this.licensePlate,
    required this.serviceName,
    required this.dpAmount,
    required this.totalPrice,
    required this.bankAccount,
    required this.storeId,
    required this.storeName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final String fullTime = json['booking_time']?.toString() ?? '';
    String date = '';
    String time = '';
    if (fullTime.contains('T')) {
      final split = fullTime.split('T');
      date = split.first;
      time = split.length > 1 ? split.last.substring(0, 5) : '';
    } else if (fullTime.contains(' ')) {
      final split = fullTime.split(' ');
      date = split.first;
      time = split.length > 1 ? split.last.substring(0, 5) : '';
    }

    return BookingModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      status: json['status'] ?? 'Menunggu',
      bookingDate: date,
      bookingTime: time,
      username: json['user']?['name'] ?? json['name'] ?? '-',

      vehicleType: json['vehicle_type'] ?? '-',
      licensePlate: json['license_plate'] ?? '-',

      // ✅ perbaikan mapping serviceName
      serviceName:
          json['service_name'] ??
          json['service']?['service_name'] ??
          json['service']?['name'] ?? // ✅ fallback ke 'name'
          'Unknown',

      dpAmount: int.tryParse(json['dp_amount']?.toString() ?? '0') ?? 0,
      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0.0') ?? 0.0,
      bankAccount: json['bank_account'] ?? '-',
      storeId: int.tryParse(json['store_id']?.toString() ?? '0') ?? 0,

      // ✅ perbaikan mapping storeName
      storeName:
          json['store_name'] ?? json['store']?['store_name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "status": status,
    "username": username,
    "tanggal": bookingDate,
    "jam": bookingTime,
    "jenisKendaraan": vehicleType,
    "noPol": licensePlate,
    "layanan": serviceName,
    "dp": dpAmount,
    "totalHarga": totalPrice,
    "rekening": bankAccount,
    "storeId": storeId,
    "storeName": storeName,
  };
}
