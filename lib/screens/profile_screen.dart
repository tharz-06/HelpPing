import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'settings_screen.dart'; // adjust path if needed

class ProfileScreen extends StatelessWidget {
  final String name;
  final String role;
  final double rating;
  final int ratingCount;

  const ProfileScreen({
    super.key,
    required this.name,
    this.role = 'Trusted helper',
    this.rating = 4.5,
    this.ratingCount = 23,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // profile card
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                      colorScheme.primary.withOpacity(0.18),
                      child: Icon(Icons.person, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    // name + role + rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withOpacity(0.6),
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
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // QR code card
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      'Your Help ID',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: QrImageView(
                        data: name, // or some userId instead of name
                        size: 180,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // menu tiles
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              const ListTile(
                leading: Icon(Icons.history),
                title: Text('History'),
              ),
              const ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
