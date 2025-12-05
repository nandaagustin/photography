import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditPackageScreen extends StatefulWidget {
  final String? packageId;
  final Map<String, dynamic>? existingData;

  const EditPackageScreen({super.key, this.packageId, this.existingData});

  @override
  State<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends State<EditPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _descController.text = widget.existingData!['description'] ?? '';
      _priceController.text = widget.existingData!['price']?.toString() ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _savePackage() async {
    if (!_formKey.currentState!.validate()) return;

    final ref = FirebaseFirestore.instance.collection('packages');
    String? imageUrl = widget.existingData?['imageUrl'];

    if (_imageFile != null) {
      final uploadTask = await FirebaseStorage.instance
          .ref('packages/${DateTime.now().millisecondsSinceEpoch}.jpg')
          .putFile(_imageFile!);
      imageUrl = await uploadTask.ref.getDownloadURL();
    }

    final data = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'imageUrl': imageUrl,
    };

    if (widget.packageId == null) {
      await ref.add(data);
    } else {
      await ref.doc(widget.packageId).update(data);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.packageId == null ? 'Tambah Paket' : 'Edit Paket'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Paket'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              if (_imageFile != null)
                Image.file(_imageFile!, height: 150, fit: BoxFit.cover)
              else if (widget.existingData?['imageUrl'] != null)
                Image.network(widget.existingData!['imageUrl'], height: 150),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePackage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Simpan Paket', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
