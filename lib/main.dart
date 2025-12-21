import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:handy_bit/providers/auth_provider.dart';
import 'package:handy_bit/providers/job_provider.dart';
import 'package:handy_bit/services/locator.dart';
import 'package:handy_bit/services/firestore_services.dart';

// Screens Imports
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart'; // Ensure this file exists
import 'screens/login_screen.dart';      // Ensure this file exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocator(); // Initialize GetIt services
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => locator<AuthProvider>(),
        ),
        ChangeNotifierProvider<JobProvider>(
          create: (_) => JobProvider(firestoreService: locator<FirestoreService>()),
        ),
      ],
      child: MaterialApp(
        title: 'HandyBit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Aapki HandyBit theme colors
          primaryColor: const Color(0xFF3B82F6),
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark Background
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Home Logic
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Agar Firebase/Auth load ho raha hai
            if (auth.isLoading) {
              return const SplashScreen();
            }

            // Navigation Logic Flow:
            // 1. Agar user logged in hai -> Seedha Home Screen
            // 2. Agar logged in nahi hai -> Pehle Onboarding dikhao
            if (auth.isLoggedIn) {
              return const HomeScreen();
            } else {
              // Yahan aap OnboardingScreen dikhayenge
              // Onboarding ke end mein button user ko LoginScreen par le jayega
              return const OnboardingScreen();
            }
          },
        ),
        // Named Routes for cleaner navigation
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
        },
      ),
    );
  }
}