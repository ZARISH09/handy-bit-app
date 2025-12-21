// lib/models/service_provider_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderModel {
  final String id; // Firestore doc id (uid)
  final String name;
  final String profession;
  final double price; // hourly rate
  final List<String> services; // list of category ids or service strings
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isVerified;
  final double? lat;
  final double? lng;
  final String? image;

  ServiceProviderModel({
    required this.id,
    required this.name,
    required this.profession,
    required this.price,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    this.isVerified = false,
    this.lat,
    this.lng,
    this.image,
  });

  factory ServiceProviderModel.fromMap(Map<String, dynamic> map, String docId) {
    final location = map['location'];
    double? lat;
    double? lng;
    if (location != null) {
      try {
        if (location is Map) {
          lat = (location['lat'] ?? location['latitude'])?.toDouble();
          lng = (location['lng'] ?? location['longitude'])?.toDouble();
        } else if (location is GeoPoint) {
          lat = location.latitude;
          lng = location.longitude;
        }
      } catch (_) {}
    }

    return ServiceProviderModel(
      id: docId,
      name: map['name'] ?? map['userName'] ?? '',
      profession: map['profession'] ?? map['category'] ?? '',
      price: (map['price'] ?? map['hourlyRate'] ?? 0).toDouble(),
      services: List<String>.from(map['services'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? map['reviews'] ?? 0).toInt(),
      isAvailable: (map['availability'] ?? map['isAvailable'] ?? true),
      isVerified: map['isVerified'] ?? false,
      lat: lat,
      lng: lng,
      image: map['image'] ?? map['profilePic'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'profession': profession,
      'price': price,
      'services': services,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'image': image,
    };
    if (lat != null && lng != null) {
      map['location'] = {'lat': lat, 'lng': lng};
    }
    return map;
  }
}
