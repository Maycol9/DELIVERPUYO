class OrderPhoto {
  const OrderPhoto({required this.path, required this.capturedAt});
  final String path;
  final String capturedAt;
  Map<String, dynamic> toJson() => {'path': path, 'capturedAt': capturedAt};
  factory OrderPhoto.fromJson(Map<String, dynamic> json) => OrderPhoto(
    path: json['path'] as String,
    capturedAt: json['capturedAt'] as String,
  );
}

class OrderLocation {
  const OrderLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.capturedAt,
    this.approximate = false,
  });
  final double latitude;
  final double longitude;
  final double accuracy;
  final String capturedAt;
  final bool approximate;
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'capturedAt': capturedAt,
    'approximate': approximate,
  };
  factory OrderLocation.fromJson(Map<String, dynamic> json) => OrderLocation(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    accuracy: (json['accuracy'] as num).toDouble(),
    capturedAt: json['capturedAt'] as String,
    approximate: json['approximate'] == true,
  );
}
