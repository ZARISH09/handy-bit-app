import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF36E27B);
    const backgroundDark = Color(0xFF112117);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [backgroundDark, Color(0xFF162E21), backgroundDark],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient( // FIXED: Was 'radialGradient'
                  colors: [
                    primaryGreen.withOpacity(0.12),
                    backgroundDark.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _ringController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 1.0 + (_ringController.value * 0.6),
                    child: Opacity(
                      opacity: 1.0 - _ringController.value,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryGreen.withOpacity(0.15), width: 1),
                        ),
                      ),
                    ),
                  ),
                  _buildRing(450, 0.05, primaryGreen),
                  _buildRing(600, 0.03, primaryGreen),
                ],
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.25),
                          blurRadius: 50,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.home_repair_service_rounded, size: 110, color: primaryGreen),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'HandyBit',
                style: GoogleFonts.splineSans(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
              Text(
                'Home Services Simplified',
                style: GoogleFonts.splineSans(
                  textStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 70),
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: Color(0xFF1D2F24),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LOADING',
                      style: GoogleFonts.splineSans(
                        textStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            child: Text(
              'v 2.0.4',
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(double size, double opacity, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(opacity), width: 1),
      ),
    );
  }
}