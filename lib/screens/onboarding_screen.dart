import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  // Data for the three slides
  final List<Map<String, dynamic>> _pages = [
    {
      "color": Colors.white,
      "icon": Icons.home_repair_service_rounded,
      "title": "All Home Services\nin One App",
      "desc": "Find trusted professionals for cleaning, repairs, and installations with just a few taps.",
      "dark": false,
    },
    {
      "color": const Color(0xFF0F172A),
      "icon": Icons.verified_user_rounded,
      "title": "Verified Skilled Providers",
      "desc": "Our professionals are background-checked and rated 5-stars for your peace of mind.",
      "dark": true,
    },
    {
      "color": const Color(0xFFF8FAFC),
      "icon": Icons.location_on_rounded,
      "title": "Easy Booking,\nFast Response",
      "desc": "Track your professional in real-time and get the job done right without any hassle.",
      "dark": false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. PageView for Sliding
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              final textColor = page['dark'] ? Colors.white : Colors.blueGrey[900];

              return Container(
                color: page['color'],
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(page['icon'], size: 120, color: const Color(0xFF3B82F6)),
                    const SizedBox(height: 60),
                    Text(
                      page['title'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.splineSans(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      page['desc'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.splineSans(
                        fontSize: 16,
                        color: textColor!.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. Skip Button (Top Right)
          if (_currentIndex < 2)
            Positioned(
              top: 60,
              right: 20,
              child: TextButton(
                onPressed: () => _controller.jumpToPage(2),
                child: Text(
                  "Skip",
                  style: GoogleFonts.splineSans(color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ),
            ),

          // 3. Bottom Controls (Dots and Buttons)
          Positioned(
            bottom: 60,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators (Dots)
                Row(
                  children: List.generate(3, (index) => _buildDot(index)),
                ),

                // Action Button
                _currentIndex == 2 ? _buildGetStarted() : _buildNextButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildNextButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF3B82F6),
      elevation: 0,
      onPressed: () => _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
      child: const Icon(Icons.arrow_forward, color: Colors.white),
    );
  }

  Widget _buildGetStarted() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: () {
        // Navigate to Login Screen
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: Text(
        "Get Started",
        style: GoogleFonts.splineSans(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}