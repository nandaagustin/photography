class BookingModel {
  final String id;
  final String packageId;
  final String userId;
  final String name;
  final String phone;
  final String date;
  final String location;
  final double price;
  final String status;

  BookingModel({
    required this.id,
    required this.packageId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.date,
    required this.location,
    required this.price,
    this.status = 'Menunggu Konfirmasi',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageId': packageId,
      'userId': userId,
      'name': name,
      'phone': phone,
      'date': date,
      'location': location,
      'price': price,
      'status': status,
    };
  }
}
