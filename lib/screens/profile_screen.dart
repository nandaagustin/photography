import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String fullName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (doc.exists) {
          setState(() {
            fullName = doc['name'] ?? '';
            email = user!.email ?? '';
          });
        }
      } catch (e) {
        debugPrint('Error loading user: $e');
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.lightBlue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              fullName.isNotEmpty ? fullName : 'Memuat...',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Keluar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
