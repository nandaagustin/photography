class PackageModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory PackageModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PackageModel(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
