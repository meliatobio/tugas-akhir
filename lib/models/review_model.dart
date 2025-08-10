class ReviewModel {
  final String
  userName; // kalau tidak ada di response, bisa pakai default/optional
  final double rating;
  final String comment;

  ReviewModel({
    required this.userName,
    required this.rating,
    required this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userName:
          json['user_name'] ??
          'Anonim', // Kalau API tidak kirim user_name, kasih default
      rating:
          double.tryParse(json['rate'].toString()) ??
          0.0, // Perbaiki key di sini
      comment: json['message'] ?? '', // Perbaiki key di sini
    );
  }
}
