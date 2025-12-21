// Simplified Firebase Options for Android-only development
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // For web and other platforms, use Android config as fallback
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjlz7VxOag4XcddylG1Ljhz8OtboNARqE',
    appId: '1:331378749707:android:d996f47ddc47dfdd13720e',
    messagingSenderId: '331378749707',
    projectId: 'fixly-e3f93',
    storageBucket: 'fixly-e3f93.firebasestorage.app',
  );
}