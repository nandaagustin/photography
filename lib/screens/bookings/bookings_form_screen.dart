import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/package_model.dart';

class BookingFormScreen extends StatefulWidget {
  final PackageModel selectedPackage;
  const BookingFormScreen({super.key, required this.selectedPackage});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user?.uid,
        'userName': _nameController.text.trim(),
        'packageId': widget.selectedPackage.id,
        'packageName': widget.selectedPackage.name,
        'price': widget.selectedPackage.price,
        'date': _dateController.text.trim(),
        'location': _locationController.text.trim(),
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemesanan berhasil dikirim!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pkg = widget.selectedPackage;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesan ${pkg.name}'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // info paket
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(pkg.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pkg.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(pkg.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(
                          'Rp ${pkg.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // form pemesanan
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pemotretan',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Tanggal harus dipilih' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi Pemotretan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Tambahan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: Text(
                        _isSubmitting ? 'Mengirim...' : 'Kirim Pemesanan',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitBooking,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
