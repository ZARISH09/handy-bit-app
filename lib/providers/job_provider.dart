import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/job_model.dart';
import '../services/firestore_services.dart';

class JobProvider with ChangeNotifier {
  final FirestoreService firestoreService;

  JobProvider({required this.firestoreService});

  StreamSubscription? _providerStream;
  StreamSubscription? _leadStream;

  List<UserModel> _nearbyProviders = [];
  List<JobModel> _nearbyLeads = [];

  bool _isFetching = false;

  List<UserModel> get nearbyProviders => _nearbyProviders;
  List<JobModel> get nearbyLeads => _nearbyLeads;
  bool get isFetching => _isFetching;

  // -------------------------------
  // CUSTOMER: fetch nearby providers
  // -------------------------------
  Future<void> fetchNearbyProviders(String serviceId, Position pos) async {
    _isFetching = true;
    notifyListeners();

    _providerStream?.cancel();

    final userGeo = GeoPoint(pos.latitude, pos.longitude);

    _providerStream = firestoreService
        .streamNearbyProviders(userGeo, serviceId)
        .listen((providers) {
      _nearbyProviders = providers;
      _isFetching = false;
      notifyListeners();
    });
  }

  // -------------------------------
  // PROVIDER: fetch nearby job leads
  // -------------------------------
  Future<void> fetchNearbyJobLeads(Position pos) async {
    _isFetching = true;
    notifyListeners();

    _leadStream?.cancel();

    final providerGeo = GeoPoint(pos.latitude, pos.longitude);

    _leadStream = firestoreService
        .streamNearbyJobLeads(providerGeo)
        .listen((jobs) {
      _nearbyLeads = jobs;
      _isFetching = false;
      notifyListeners();
    });
  }

  // -------------------------------
  // Create new job
  // -------------------------------
  Future<void> createNewJob(JobModel job) async {
    _isFetching = true;
    notifyListeners();

    await firestoreService.createJob(job);

    _isFetching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _providerStream?.cancel();
    _leadStream?.cancel();
    super.dispose();
  }
}
