import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handy_bit/models/user_model.dart';
import 'package:handy_bit/models/job_model.dart';
import 'package:handy_bit/models/service_provider.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      throw e;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }

  // Job operations
  Future<List<JobModel>> getNearbyJobs(double lat, double lng, double radiusInKm) async {
    try {
      // Note: This is a simplified version. For production,
      // you'd need geoqueries with Firestore geohashes
      final query = await _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'pending')
          .get();

      return query.docs.map((doc) => JobModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting nearby jobs: $e');
      return [];
    }
  }

  Stream<List<UserModel>> streamNearbyProviders(GeoPoint userGeo, String serviceId) {
    // This is a placeholder implementation. In a real app, you would use a geoquery.
    return _firestore.collection('users').where('role', isEqualTo: 'provider').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Stream<List<JobModel>> streamNearbyJobLeads(GeoPoint providerGeo) {
    // This is a placeholder implementation. In a real app, you would use a geoquery.
    return _firestore.collection('jobs').where('status', isEqualTo: 'pending').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => JobModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> createJob(JobModel job) async {
    try {
      await _firestore.collection('jobs').add(job.toMap());
    } catch (e) {
      print('Error creating job: $e');
      throw e;
    }
  }

  // ============================================
  // NEW: Service Provider Operations (Requirement #6)
  // ============================================

  /// Create a new service provider in "service_providers" collection
  Future<String> createServiceProvider(ServiceProvider provider) async {
    try {
      final docRef = await _firestore.collection('service_providers').add(provider.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating service provider: $e');
      throw e;
    }
  }

  /// Get a service provider by ID
  Future<ServiceProvider?> getProviderById(String providerId) async {
    try {
      final doc = await _firestore.collection('service_providers').doc(providerId).get();
      if (doc.exists) {
        return ServiceProvider.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting provider by ID: $e');
      return null;
    }
  }

  /// Stream available service providers
  Stream<List<ServiceProvider>> streamAvailableProviders() {
    return _firestore
        .collection('service_providers')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ServiceProvider.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream available providers filtered by service
  Stream<List<ServiceProvider>> streamAvailableProvidersByService(String service) {
    return _firestore
        .collection('service_providers')
        .where('isAvailable', isEqualTo: true)
        .where('services', arrayContains: service)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ServiceProvider.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Update service provider
  Future<void> updateServiceProvider(String providerId, ServiceProvider provider) async {
    try {
      await _firestore.collection('service_providers').doc(providerId).update(provider.toMap());
    } catch (e) {
      print('Error updating service provider: $e');
      throw e;
    }
  }

  // ============================================
  // NEW: Booking Operations (Requirement #5, #6)
  // ============================================

  /// Create a new booking in "bookings" collection
  Future<String> createBooking({
    required String userId,
    required String providerId,
    required String providerName,
    required String service,
    required DateTime date,
    required String time,
    required String address,
    required bool urgent,
    String? specialInstructions,
    required double totalPrice,
  }) async {
    try {
      final bookingData = {
        'userId': userId,
        'providerId': providerId,
        'providerName': providerName,
        'service': service,
        'date': Timestamp.fromDate(date),
        'time': time,
        'address': address,
        'urgent': urgent,
        'specialInstructions': specialInstructions ?? '',
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      final docRef = await _firestore.collection('bookings').add(bookingData);
      return docRef.id;
    } catch (e) {
      print('Error creating booking: $e');
      throw e;
    }
  }

  /// Get bookings for a user
  Stream<List<Map<String, dynamic>>> streamUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get bookings for a provider
  Stream<List<Map<String, dynamic>>> streamProviderBookings(String providerId) {
    return _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({'status': status});
    } catch (e) {
      print('Error updating booking status: $e');
      throw e;
    }
  }

// Add other Firestore operations as needed
}