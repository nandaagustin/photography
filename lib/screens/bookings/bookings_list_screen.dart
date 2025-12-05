import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingsListScreen extends StatelessWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pemesanan Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.lightBlue[50],
      body: user == null
          ? const Center(child: Text('Silakan login untuk melihat pesanan.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pesanan.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final packageName = booking['packageName'] ?? 'Tanpa Nama Paket';
                    final status = booking['status'] ?? 'Menunggu Konfirmasi';
                    final date = (booking['date'] as Timestamp).toDate();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.lightBlue[200]!, Colors.lightBlue[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.lightBlue.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.lightBlue,
                          child: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                        title: Text(
                          packageName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Tanggal: ${DateFormat('dd MMM yyyy').format(date)}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: status == 'Menunggu Konfirmasi'
                                    ? Colors.orange
                                    : status == 'Disetujui'
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(packageName),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tanggal Pemotretan: ${DateFormat('dd MMM yyyy').format(date)}'),
                                  Text('Status: $status'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
