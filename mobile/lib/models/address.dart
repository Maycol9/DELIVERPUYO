class Address {
  const Address({
    required this.id,
    required this.label,
    required this.address,
    this.reference,
  });

  final String id;
  final String label;
  final String address;
  final String? reference;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Dirección',
      address: json['address']?.toString() ?? '',
      reference: json['reference']?.toString(),
    );
  }
}
