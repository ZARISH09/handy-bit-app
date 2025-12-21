import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;              // Firestore document ID
  final String customerId;      // Who created the job
  final String serviceId;       // Type of service: plumbing, cleaning, etc.
  final String description;     // Job details
  final GeoPoint location;      // Customer location
  final DateTime createdAt;     // Timestamp
  final bool isUrgent;          // Emergency flag

  JobModel({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.description,
    required this.location,
    required this.createdAt,
    required this.isUrgent,
  });

  // Convert Firestore → Model
  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      customerId: map['customerId'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: map['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isUrgent: map['isUrgent'] as bool? ?? false,
    );
  }

  // Convert Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'serviceId': serviceId,
      'description': description,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'isUrgent': isUrgent,
    };
  }
}
