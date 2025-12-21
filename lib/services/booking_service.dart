import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// -------------------------------------------------------------------------
  /// CREATE BOOKING
  /// -------------------------------------------------------------------------
  Future<String?> createBooking({
    required String userId,
    required String providerId,
    required String providerName,
    required String profession,
    required double price,
    required DateTime date,
    required String address,
    required bool urgent,
    required String timeSlot,
    required String specialInstructions,
  }) async {
    try {
      final docRef = _firestore.collection('bookings').doc();

      await docRef.set({
        'bookingId': docRef.id,
        'customerId': userId,
        'providerId': providerId,
        'providerName': providerName,
        'service': profession,
        'date': Timestamp.fromDate(date),
        'time': timeSlot,
        'address': address,
        'urgent': urgent,
        'specialInstructions': specialInstructions,
        'price': urgent ? price * 1.3 : price,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print("🔥 Booking creation error: $e");
      return null;
    }
  }

  /// -------------------------------------------------------------------------
  /// GET USER BOOKINGS (CUSTOMER SIDE)
  /// -------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// -------------------------------------------------------------------------
  /// GET PROVIDER BOOKINGS
  /// -------------------------------------------------------------------------
  Stream<List<Map<String, dynamic>>> getProviderBookings(String providerId) {
    return _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// -------------------------------------------------------------------------
  /// UPDATE BOOKING STATUS
  /// status = pending / accepted / completed / cancelled
  /// -------------------------------------------------------------------------
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      print("🔥 Booking status update error: $e");
      return false;
    }
  }

  /// -------------------------------------------------------------------------
  /// DELETE BOOKING
  /// -------------------------------------------------------------------------
  Future<bool> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
      return true;
    } catch (e) {
      print("🔥 Booking deletion error: $e");
      return false;
    }
  }

  /// -------------------------------------------------------------------------
  /// CHECK IF A PROVIDER IS FREE ON A SPECIFIC DATE/TIME
  /// -------------------------------------------------------------------------
  Future<bool> isProviderAvailable({
    required String providerId,
    required DateTime date,
    required String timeSlot,
  }) async {
    final snap = await _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .where('date', isEqualTo: Timestamp.fromDate(date))
        .where('time', isEqualTo: timeSlot)
        .get();

    return snap.docs.isEmpty; // empty = available
  }
}
