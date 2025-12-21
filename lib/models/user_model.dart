import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  final String uid;
  final String name;

  /// 'customer' or 'provider'
  final String role;

  /// Location
  final double? latitude;
  final double? longitude;

  /// Provider-related
  final bool isServiceProvider;
  final bool isVerified;
  final List<String> serviceCategoryIDs;
  final double? rating;

  /// Contact
  final String? email;
  final String? phoneNumber;

  /// Profile
  final String? profileImage;

  UserModel({
    required this.uid,
    required this.name,
    required this.role,
    this.latitude,
    this.longitude,
    this.isServiceProvider = false,
    this.isVerified = false,
    this.serviceCategoryIDs = const [],
    this.rating,
    this.email,
    this.phoneNumber,
    this.profileImage,
  });

  /// 🔁 Firestore → Model
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'User',
      role: map['role'] ?? 'customer',

      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),

      isServiceProvider: map['isServiceProvider'] ?? false,
      isVerified: map['isVerified'] ?? false,

      serviceCategoryIDs:
      List<String>.from(map['serviceCategoryIDs'] ?? []),

      rating: (map['rating'] as num?)?.toDouble(),

      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profileImage: map['profileImage'],
    );
  }

  /// 🔁 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'role': role,
      'latitude': latitude,
      'longitude': longitude,
      'isServiceProvider': isServiceProvider,
      'isVerified': isVerified,
      'serviceCategoryIDs': serviceCategoryIDs,
      'rating': rating,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// ✏ Update helper
  UserModel copyWith({
    String? uid,
    String? name,
    String? role,
    double? latitude,
    double? longitude,
    bool? isServiceProvider,
    bool? isVerified,
    List<String>? serviceCategoryIDs,
    double? rating,
    String? email,
    String? phoneNumber,
    String? profileImage,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      role: role ?? this.role,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isServiceProvider:
      isServiceProvider ?? this.isServiceProvider,
      isVerified: isVerified ?? this.isVerified,
      serviceCategoryIDs:
      serviceCategoryIDs ?? this.serviceCategoryIDs,
      rating: rating ?? this.rating,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
