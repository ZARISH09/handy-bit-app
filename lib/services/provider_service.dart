// lib/services/provider_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_provider_model.dart';

class ProviderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ServiceProviderModel>> streamAvailableProviders() {
    return _db
        .collection('service_providers')
        .where('availability', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ServiceProviderModel.fromMap(d.data(), d.id))
        .toList());
  }

  Future<ServiceProviderModel?> getProviderById(String id) async {
    final doc = await _db.collection('service_providers').doc(id).get();
    if (!doc.exists) return null;
    return ServiceProviderModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> createOrUpdateProvider(ServiceProviderModel provider) async {
    await _db
        .collection('service_providers')
        .doc(provider.id)
        .set(provider.toMap(), SetOptions(merge: true));
  }

  Future<void> updateAvailability(String providerId, bool availability) async {
    await _db
        .collection('service_providers')
        .doc(providerId)
        .update({'availability': availability, 'updatedAt': FieldValue.serverTimestamp()});
  }

  /// Client-side filter for nearby providers using Haversine formula.
  /// NOTE: For production use geohashes/geoqueries server-side.
  Future<List<ServiceProviderModel>> fetchProvidersNear({
    required double userLat,
    required double userLng,
    required double radiusInKm,
    String? categoryFilter, // optional: filter by service/category id
    int limit = 50,
  }) async {
    final snapshot = await _db.collection('service_providers').where('availability', isEqualTo: true).get();

    final providers = <ServiceProviderModel>[];
    for (final doc in snapshot.docs) {
      final p = ServiceProviderModel.fromMap(doc.data(), doc.id);
      if (p.lat == null || p.lng == null) continue;
      final dist = _distanceBetween(userLat, userLng, p.lat!, p.lng!);
      if (dist <= radiusInKm) {
        if (categoryFilter == null || p.services.contains(categoryFilter)) {
          providers.add(p);
        }
      }
    }
    providers.sort((a, b) {
      final da = a.lat != null && a.lng != null ? _distanceBetween(userLat, userLng, a.lat!, a.lng!) : double.infinity;
      final db = b.lat != null && b.lng != null ? _distanceBetween(userLat, userLng, b.lat!, b.lng!) : double.infinity;
      return da.compareTo(db);
    });
    if (providers.length > limit) return providers.sublist(0, limit);
    return providers;
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula
    const R = 6371; // km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);
}
