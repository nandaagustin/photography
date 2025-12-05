import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingsRef = FirebaseFirestore.instance.collection('bookings');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pemesanan'),
        backgroundColor: Colors.lightBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['customerName'] ?? 'Tanpa Nama'),
                  subtitle: Text('Status: ${data['status'] ?? 'pending'}'),
                  trailing: DropdownButton<String>(
                    value: data['status'] ?? 'pending',
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'diterima', child: Text('Diterima')),
                      DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                      DropdownMenuItem(value: 'dibatalkan', child: Text('Dibatalkan')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        bookingsRef.doc(id).update({'status': val});
                      }
                    },
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
