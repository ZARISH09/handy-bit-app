import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class ServiceProvider {
  final String id;
  final String name;
  final String profession;
  final double rating;
  final int reviewCount;
  final double price;
  final String image;
  final bool isAvailable;
  final double distance;
  final String description;
  final List<String> services;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.image,
    required this.isAvailable,
    required this.distance,
    required this.description,
    required this.services,
  });
}

class Booking {
  final String id;
  final ServiceProvider provider;
  final DateTime dateTime;
  final String address;
  final double totalPrice;
  final String status;
  final bool isUrgent;

  Booking({
    required this.id,
    required this.provider,
    required this.dateTime,
    required this.address,
    required this.totalPrice,
    required this.status,
    required this.isUrgent,
  });
}