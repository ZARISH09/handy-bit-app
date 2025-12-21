import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// SCREEN 1: All Home Services
class PageOne extends StatelessWidget {
  const PageOne({super.key});
  @override
  Widget build(BuildContext context) {
    return _BasePage(
      color: Colors.white,
      icon: Icons.home_repair_service_rounded,
      title: "All Home Services\nin One App",
      description: "Find trusted professionals for cleaning, repairs, and installations with just a few taps.",
      iconColor: const Color(0xFF3B82F6),
      textColor: Colors.slate[900]!,
    );
  }
}

// SCREEN 2: Verified Providers
class PageTwo extends StatelessWidget {
  const PageTwo({super.key});
  @override
  Widget build(BuildContext context) {
    return _BasePage(
      color: const Color(0xFF0F172A), // Dark Theme
      icon: Icons.verified_user_rounded,
      title: "Verified Skilled Providers",
      description: "Our professionals are background-checked and rated 5-stars for your peace of mind.",
      iconColor: const Color(0xFF3B82F6),
      textColor: Colors.white,
    );
  }
}

// SCREEN 3: Easy Booking
class PageThree extends StatelessWidget {
  const PageThree({super.key});
  @override
  Widget build(BuildContext context) {
    return _BasePage(
      color: const Color(0xFFF8FAFC),
      icon: Icons.location_on_rounded,
      title: "Easy Booking,\nFast Response",
      description: "Track your professional in real-time and get the job done right without any hassle.",
      iconColor: const Color(0xFF3B82F6),
      textColor: Colors.slate[900]!,
    );
  }
}

// Common Layout Helper
class _BasePage extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color textColor;

  const _BasePage({
    required this.color, required this.icon, required this.title,
    required this.description, required this.iconColor, required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: iconColor),
          const SizedBox(height: 60),
          Text(title, textAlign: TextAlign.center,
              style: GoogleFonts.splineSans(fontSize: 30, fontWeight: FontWeight.bold, color: textColor, height: 1.2)),
          const SizedBox(height: 20),
          Text(description, textAlign: TextAlign.center,
              style: GoogleFonts.splineSans(fontSize: 16, color: textColor.withOpacity(0.6), height: 1.5)),
        ],
      ),
    );
  }
}