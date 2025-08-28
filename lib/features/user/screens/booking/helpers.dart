Map<String, dynamic> mapBookingToTransaction(Map<String, dynamic> data) {
  return {
    'vehicle_type': data['vehicle_type'] ?? '-',
    'service_name': data['service'] != null
        ? data['service']['name'] ?? '-'
        : data['service_name'] ?? '-',
    'license_plate': data['license_plate'] ?? '-',
    'total_price': data['total_price'] ?? 0,
    'notes': data['notes'] ?? '-',
    'status': data['status'] ?? '-',
    'payment_method': data['payment_method'] ?? '-',
    'booking_time': data['booking_time'] ?? '-',
    'user_id': data['user_id'] ?? 0,
    'store_id': data['store_id'] ?? 0,
    'service_id': data['service_id'] ?? 0,
  };
}
