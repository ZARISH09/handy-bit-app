import 'package:flutter/material.dart';
// lib/widget/provider_card.dart
import 'package:flutter/material.dart';
import '../models/service_provider_model.dart';
import '../screens/service_detail_screen.dart'; // adjust import path if needed

class ProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final double? distanceKm; // optional, precomputed
  final VoidCallback? onTap;

  const ProviderCard({
    super.key,
    required this.provider,
    this.distanceKm,
    this.onTap,
  });

  @override
  Widget _buildBecomeProviderCard() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceProviderProfileScreen(
              user: authProvider.firebaseUser, // pass the Firebase user
              userName: authProvider.currentUser!.name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            image != null && image.isNotEmpty
                ? CircleAvatar(radius: 28, backgroundImage: NetworkImage(image))
                : Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Color(0xFF2563EB)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(provider.profession, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildStars(provider.rating),
                      const SizedBox(width: 8),
                      if (distanceKm != null)
                        Text('${distanceKm!.toStringAsFixed(1)} km', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${provider.price.toStringAsFixed(0)}/h', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: provider.isAvailable ? Colors.green.withOpacity(0.08) : Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(provider.isAvailable ? 'Available' : 'Offline', style: TextStyle(color: provider.isAvailable ? Colors.green : Colors.grey[600], fontSize: 12)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    final filled = rating.floor();
    return Row(
      children: List.generate(5, (i) {
        if (i < filled) return const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B));
        return const Icon(Icons.star_border, size: 14, color: Color(0xFFF59E0B));
      }),
    );
  }
}
