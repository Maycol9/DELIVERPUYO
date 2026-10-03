import 'package:json_annotation/json_annotation.dart';
part 'product.g.dart';

@JsonSerializable()
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description,
    this.categoryName,
  });

  final String id;
  final String name;
  @JsonKey(fromJson: _toDouble)
  final double price;
  @JsonKey(fromJson: _toInt)
  final int stock;
  final String? imageUrl;
  final String? description;
  @JsonKey(
    name: 'category',
    fromJson: _categoryFromJson,
    toJson: _categoryToJson,
  )
  final String? categoryName;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
  static String? _categoryFromJson(Object? value) =>
      value is Map ? value['name'] as String? : null;
  static Map<String, dynamic>? _categoryToJson(String? value) =>
      value == null ? null : {'name': value};

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
