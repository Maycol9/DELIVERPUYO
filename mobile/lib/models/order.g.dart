// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderSummary _$OrderSummaryFromJson(Map<String, dynamic> json) => OrderSummary(
  id: json['id'] as String,
  status: json['status'] as String,
  total: OrderSummary._toDouble(json['total']),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$OrderSummaryToJson(OrderSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'total': instance.total,
      'createdAt': instance.createdAt,
    };
