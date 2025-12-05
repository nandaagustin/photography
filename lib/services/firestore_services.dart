import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SIMPAN DATA USER BARU
  Future<void> saveUserData({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal menyimpan data user: $e');
    }
  }

  // AMBIL DATA USER SAAT LOGIN
  Future<DocumentSnapshot?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await _db.collection('users').doc(user.uid).get();
      }
    } catch (e) {
      throw Exception('Gagal mengambil data user: $e');
    }
    return null;
  }

  // TAMBAH DATA BOOKING
  Future<void> addBooking(Map<String, dynamic> data) async {
    try {
      await _db.collection('bookings').add({
        ...data,
        'userId': _auth.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal menambahkan booking: $e');
    }
  }

  // STREAM SEMUA BOOKING
  Stream<QuerySnapshot> getBookings() {
    return _db.collection('bookings').orderBy('createdAt', descending: true).snapshots();
  }

  // HAPUS BOOKING BERDASARKAN ID
  Future<void> deleteBooking(String id) async {
    try {
      await _db.collection('bookings').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus booking: $e');
    }
  }

  // TAMBAH DATA PACKAGE
  Future<void> addPackage(Map<String, dynamic> data) async {
    try {
      await _db.collection('package').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal menambahkan package: $e');
    }
  }

  // STREAM SEMUA PACKAGE
  Stream<QuerySnapshot> getPackages() {
    return _db.collection('package').orderBy('createdAt', descending: true).snapshots();
  }

  // HAPUS PACKAGE BERDASARKAN ID
  Future<void> deletePackage(String id) async {
    try {
      await _db.collection('package').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus package: $e');
    }
  }
}
