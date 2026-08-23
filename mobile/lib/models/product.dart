class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.categoryName,
  });

  final String id;
  final String name;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? categoryName;

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Producto sin nombre',
      price: _toDouble(json['price']),
      stock: _toInt(json['stock']),
      imageUrl: json['imageUrl']?.toString(),
      categoryName: category is Map<String, dynamic>
          ? category['name']?.toString()
          : null,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
