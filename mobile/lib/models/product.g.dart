// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  price: Product._toDouble(json['price']),
  stock: Product._toInt(json['stock']),
  imageUrl: json['imageUrl'] as String?,
  description: json['description'] as String?,
  categoryName: Product._categoryFromJson(json['category']),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'stock': instance.stock,
  'imageUrl': instance.imageUrl,
  'description': instance.description,
  'category': Product._categoryToJson(instance.categoryName),
};
