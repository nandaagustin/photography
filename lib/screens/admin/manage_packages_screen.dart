import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_package_screen.dart';

class ManagePackagesScreen extends StatelessWidget {
  const ManagePackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final packagesRef = FirebaseFirestore.instance.collection('packages');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Paket Foto'),
        backgroundColor: Colors.lightBlue,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditPackageScreen()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: packagesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: data['imageUrl'] != null
                      ? Image.network(data['imageUrl'], width: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(data['name'] ?? 'Tanpa Nama'),
                  subtitle: Text('Rp ${data['price'] ?? 0}'),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditPackageScreen(
                              packageId: docs[i].id,
                              existingData: data,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        packagesRef.doc(docs[i].id).delete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
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
