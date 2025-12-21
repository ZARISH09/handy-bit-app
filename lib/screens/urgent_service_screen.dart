import 'package:flutter/material.dart';
import '../models/service_model.dart';
import 'service_detail_screen.dart';

class UrgentServiceScreen extends StatefulWidget {
  const UrgentServiceScreen({super.key});

  @override
  State<UrgentServiceScreen> createState() => _UrgentServiceScreenState();
}

class _UrgentServiceScreenState extends State<UrgentServiceScreen> {
  final List<ServiceProvider> _urgentProviders = [
    ServiceProvider(
      id: '101',
      name: 'Emergency Plumbing Team',
      profession: '24/7 Plumbing Emergency',
      rating: 4.9,
      reviewCount: 234,
      price: 120,
      image: '',
      isAvailable: true,
      distance: 1.2,
      description: '24/7 emergency plumbing services. Fast response within 30 minutes. Available for all plumbing emergencies.',
      services: ['Pipe Burst', 'Water Leak', 'Drain Blockage', 'Emergency Repair'],
    ),
    ServiceProvider(
      id: '102',
      name: 'Quick Electric Response',
      profession: 'Emergency Electrician',
      rating: 4.8,
      reviewCount: 167,
      price: 110,
      image: '',
      isAvailable: true,
      distance: 2.1,
      description: 'Certified emergency electrician. Power outage solutions and electrical safety inspections.',
      services: ['Power Outage', 'Electrical Hazard', 'Wiring Emergency', 'Circuit Breaker'],
    ),
    ServiceProvider(
      id: '103',
      name: 'AC Emergency Repair',
      profession: 'HVAC Emergency Service',
      rating: 4.7,
      reviewCount: 189,
      price: 130,
      image: '',
      isAvailable: true,
      distance: 3.5,
      description: 'Emergency AC repair services. Available 24/7 for critical cooling system failures.',
      services: ['AC Breakdown', 'Cooling Failure', 'System Overheat', 'Emergency Repair'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      appBar: AppBar(
        title: const Text(
          'Urgent Services',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmergencyHeader(),
            const SizedBox(height: 24),
            _buildUrgentProvidersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Service',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Immediate assistance with 30-min response time. Higher rates apply for urgent requests.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentProvidersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Emergency Providers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: _urgentProviders.map((provider) {
            return _buildUrgentProviderCard(provider);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUrgentProviderCard(ServiceProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(provider: provider),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency,
                color: Color(0xFFDC2626),
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.profession,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRatingStars(provider.rating),
                      const SizedBox(width: 8),
                      Text(
                        '${provider.rating} (${provider.reviewCount})',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${provider.price}/hour',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '30-min response',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: const Color(0xFFF59E0B),
          size: 16,
        );
      }),
    );
  }
}