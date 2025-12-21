// models/service_provider.dart
class ServiceProvider {
  final String id;
  final String name;
  final String profession;
  final double price;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isVerified;
  final double? latitude;
  final double? longitude;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.profession,
    required this.price,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    this.isVerified = false,
    this.latitude,
    this.longitude,
  });

  factory ServiceProvider.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceProvider(
      id: docId,
      name: map['name'] ?? '',
      profession: map['profession'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      services: List<String>.from(map['services'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      isVerified: map['isVerified'] ?? false,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profession': profession,
      'price': price,
      'services': services,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
