import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_pemesanan_jasa_fotografi/screens/auth/login_screen.dart';
import 'package:sistem_pemesanan_jasa_fotografi/screens/services/package_list_screen.dart';
import 'package:sistem_pemesanan_jasa_fotografi/screens/bookings/bookings_list_screen.dart';
import 'package:sistem_pemesanan_jasa_fotografi/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String fullName = '';
  String greeting = '';

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _loadUserName();
  }

  // menentukan ucapan berdasarkan waktu
  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      greeting = 'Selamat pagi';
    } else if (hour >= 11 && hour < 15) {
      greeting = 'Selamat siang';
    } else if (hour >= 15 && hour < 18) {
      greeting = 'Selamat sore';
    } else {
      greeting = 'Selamat malam';
    }
  }

  // ambil nama user dari firestore
  Future<void> _loadUserName() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (doc.exists && doc.data()!.containsKey('name')) {
          setState(() {
            fullName = doc['name'];
          });
        } else {
          setState(() {
            fullName = user!.email ?? 'Pengguna';
          });
        }
      } catch (e) {
        setState(() {
          fullName = user!.email ?? 'Pengguna';
        });
      }
    }
  }

  // fungsi logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'Beranda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${fullName.isNotEmpty ? fullName : '...'} 👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  // navigasi ke daftar paket foto
                  _buildMenuCard(
                    icon: Icons.camera_alt,
                    label: 'Paket Foto',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PackageListScreen(),
                        ),
                      );
                    },
                  ),

                  // navigasi ke daftar pesanan user
                  _buildMenuCard(
                    icon: Icons.assignment,
                    label: 'Pemesanan Saya',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingsListScreen(),
                        ),
                      );
                    },
                  ),

                  // navigasi ke profil
                  _buildMenuCard(
                    icon: Icons.account_circle,
                    label: 'Profil',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),

                  // tombol keluar
                  _buildMenuCard(
                    icon: Icons.logout,
                    label: 'Keluar',
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget card menu
  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.lightBlue),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
