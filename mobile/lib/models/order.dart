class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final String status;
  final double total;
  final String createdAt;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      total: _toDouble(json['total']),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

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
  });

  final String addressId;
  final String productId;
  final String quantity;

  bool get isEmpty =>
      addressId.isEmpty && productId.isEmpty && quantity.isEmpty;

  OrderDraft copyWith({
    String? addressId,
    String? productId,
    String? quantity,
  }) {
    return OrderDraft(
      addressId: addressId ?? this.addressId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
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
}
