import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/package_model.dart';
import '../bookings/bookings_form_screen.dart';

class PackageListScreen extends StatelessWidget {
  const PackageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'Daftar Paket Foto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('packages').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final packages = snapshot.data!.docs.map((doc) {
            return PackageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final pkg = packages[index]; // ✅ ini definisi 'pkg'

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingFormScreen(selectedPackage: pkg),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    leading: const Icon(Icons.camera_alt, size: 40, color: Colors.lightBlue),
                    title: Text(
                      pkg.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(pkg.description),
                    trailing: Text(
                      "Rp ${pkg.price.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
