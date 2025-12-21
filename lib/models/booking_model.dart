import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String customerId;
  final String providerId;
  final String providerName;
  final String service;
  final List<String> services;
  final DateTime date;
  final String time;
  final String address;
  final bool urgent;
  final String specialInstructions;
  final double totalPrice;
  final String status; // pending / completed / canceled
  final DateTime createdAt;

  BookingModel({
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.providerName,
    required this.service,
    required this.services,
    required this.date,
    required this.time,
    required this.address,
    required this.urgent,
    required this.specialInstructions,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  // 🔥 Convert Firestore → Model
  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      bookingId: id,
      customerId: map['customerId'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      service: map['service'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      address: map['address'] ?? '',
      urgent: map['urgent'] ?? false,
      specialInstructions: map['specialInstructions'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🔥 Convert Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'providerId': providerId,
      'providerName': providerName,
      'service': service,
      'services': services,
      'date': Timestamp.fromDate(date),
      'time': time,
      'address': address,
      'urgent': urgent,
      'specialInstructions': specialInstructions,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
