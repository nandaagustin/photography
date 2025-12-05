import 'package:flutter/material.dart';
import 'manage_packages_screen.dart';
import 'manage_bookings_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildCard(
              icon: Icons.camera_alt,
              label: 'Kelola Paket',
              color: Colors.blueAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagePackagesScreen()),
              ),
            ),
            _buildCard(
              icon: Icons.assignment,
              label: 'Kelola Pemesanan',
              color: Colors.orangeAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageBookingsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
