import 'package:json_annotation/json_annotation.dart';
import 'order_evidence.dart';
part 'order.g.dart';

@JsonSerializable()
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final String status;
  @JsonKey(fromJson: _toDouble)
  final double total;
  final String createdAt;

  factory OrderSummary.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$OrderSummaryToJson(this);

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class OrderDraft {
  const OrderDraft({
    this.addressId = '',
    this.productId = '',
    this.quantity = '',
    this.photo,
    this.location,
  });

  final String addressId;
  final String productId;
  final String quantity;
  final OrderPhoto? photo;
  final OrderLocation? location;

  bool get isEmpty =>
      addressId.isEmpty &&
      productId.isEmpty &&
      quantity.isEmpty &&
      photo == null &&
      location == null;

  OrderDraft copyWith({
    String? addressId,
    String? productId,
    String? quantity,
    OrderPhoto? photo,
    OrderLocation? location,
    bool removePhoto = false,
    bool removeLocation = false,
  }) {
    return OrderDraft(
      addressId: addressId ?? this.addressId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      photo: removePhoto ? null : photo ?? this.photo,
      location: removeLocation ? null : location ?? this.location,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'addressId': addressId,
      'items': [
        {
          'productId': productId,
          'quantity': int.tryParse(quantity) ?? quantity,
        },
      ],
    };
  }

  Map<String, dynamic> toLocalJson() => {
    'addressId': addressId,
    'productId': productId,
    'quantity': quantity,
    if (photo != null) 'photo': photo!.toJson(),
    if (location != null) 'location': location!.toJson(),
  };

  factory OrderDraft.fromLocalJson(Map<String, dynamic> value) => OrderDraft(
    addressId: value['addressId'] as String? ?? '',
    productId: value['productId'] as String? ?? '',
    quantity: value['quantity'] as String? ?? '',
    photo: value['photo'] == null
        ? null
        : OrderPhoto.fromJson(Map<String, dynamic>.from(value['photo'] as Map)),
    location: value['location'] == null
        ? null
        : OrderLocation.fromJson(
            Map<String, dynamic>.from(value['location'] as Map),
          ),
  );
}
