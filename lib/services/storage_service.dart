import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file (File)
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Gagal mengupload file: $e');
    }
  }

  // Upload file dari bytes (Flutter Web support)
  Future<String> uploadBytes(Uint8List bytes, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(bytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Gagal mengupload gambar: $e');
    }
  }

  // Hapus file dari storage
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Gagal menghapus file: $e');
    }
  }
}
