import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../services/firestore_services.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService firestoreService;

  AuthProvider({required this.firestoreService}) {
    _startAuthListener();
  }

  UserModel? _currentUser;
  bool _isLoading = true;

  StreamSubscription<User?>? _authListener;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isProvider => _currentUser?.role == 'provider';

  void _startAuthListener() {
    _authListener = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _isLoading = true;
    notifyListeners();

    if (firebaseUser == null) {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _currentUser = await firestoreService.getUser(firebaseUser.uid);

      if (_currentUser == null) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? "New User",
          role: "customer",
        );

        await firestoreService.updateUser(newUser);
        _currentUser = newUser;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Auth state error: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateUserProfile(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> updateLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions denied.");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_currentUser == null) return false;

      final updatedUser = _currentUser!.copyWith(latitude: position.latitude, longitude: position.longitude);
      await firestoreService.updateUser(updatedUser);

      _currentUser = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) print("Location update error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authListener?.cancel();
    super.dispose();
  }
}
