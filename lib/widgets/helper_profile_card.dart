// lib/widgets/helper_profile_card.dart
import 'package:flutter/material.dart';

class HelperProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final double rating;
  final int ratingCount;

  const HelperProfileCard({
    super.key,
    required this.name,
    this.role = 'Trusted helper',
    this.rating = 4.5,
    this.ratingCount = 23,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.star,
                      color: Colors.amber.shade700, size: 18),
                  Icon(Icons.star,
                      color: Colors.amber.shade700, size: 18),
                  Icon(Icons.star,
                      color: Colors.amber.shade700, size: 18),
                  Icon(Icons.star,
                      color: Colors.amber.shade700, size: 18),
                  Icon(Icons.star_half,
                      color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '$rating · $ratingCount reviews',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
