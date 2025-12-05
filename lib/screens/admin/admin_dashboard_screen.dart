import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // fungsi hapus paket
  Future<void> _deletePackage(String id) async {
    await FirebaseFirestore.instance.collection('packages').doc(id).delete();
  }

  // fungsi unggah gambar ke storage
  Future<String?> _uploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance
        .ref()
        .child('package_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // dialog tambah / edit paket
  void _showPackageDialog({DocumentSnapshot? package}) {
    final nameController =
        TextEditingController(text: package != null ? package['name'] : '');
    final descController =
        TextEditingController(text: package != null ? package['description'] : '');
    final priceController =
        TextEditingController(text: package != null ? package['price'].toString() : '');
    String? imageUrl = package != null ? package['imageUrl'] : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(package == null ? 'Tambah Paket' : 'Edit Paket'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final url = await _uploadImage();
                  if (url != null) {
                    setState(() => imageUrl = url);
                  }
                },
                child: imageUrl == null
                    ? Container(
                        height: 120,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Text('Klik untuk upload foto'),
                      )
                    : Image.network(imageUrl!, height: 120, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Paket'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  descController.text.isEmpty ||
                  priceController.text.isEmpty) return;

              final data = {
                'name': nameController.text,
                'description': descController.text,
                'price': double.parse(priceController.text),
                'imageUrl': imageUrl ??
                    'https://via.placeholder.com/150', // default jika tidak upload
              };

              if (package == null) {
                await FirebaseFirestore.instance.collection('packages').add(data);
              } else {
                await FirebaseFirestore.instance
                    .collection('packages')
                    .doc(package.id)
                    .update(data);
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt), text: 'Kelola Paket'),
            Tab(icon: Icon(Icons.list_alt), text: 'Status Pemesanan'),
          ],
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Kelola Paket
          _buildManagePackages(),

          // Tab Status Pemesanan
          _buildOrdersStatus(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: Colors.lightBlue,
              child: const Icon(Icons.add),
              onPressed: () => _showPackageDialog(),
            )
          : null,
    );
  }

  // daftar paket foto
  Widget _buildManagePackages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('packages').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final packages = snapshot.data!.docs;
        return ListView.builder(
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final pkg = packages[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: Image.network(pkg['imageUrl'], width: 60, fit: BoxFit.cover),
                title: Text(pkg['name']),
                subtitle: Text("Rp ${pkg['price']}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showPackageDialog(package: pkg);
                    } else if (value == 'delete') {
                      _deletePackage(pkg.id);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // daftar pemesanan
  Widget _buildOrdersStatus() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final bookings = snapshot.data!.docs;
        if (bookings.isEmpty) {
          return const Center(child: Text('Belum ada pemesanan.'));
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final data = bookings[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.lightBlue),
                title: Text(data['customerName'] ?? 'Tanpa nama'),
                subtitle: Text("Paket: ${data['packageName']} \nStatus: ${data['status']}"),
              ),
            );
          },
        );
      },
    );
  }
}
