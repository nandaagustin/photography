import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'register_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showPopup({
    required bool success,
    required String message,
    String? boldText,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: success ? Colors.green : Colors.red,
                child: Icon(
                  success ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                success ? 'Login Berhasil' : 'Login Gagal',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  children: [
                    TextSpan(text: message),
                    if (boldText != null)
                      TextSpan(
                        text: boldText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onOk != null) onOk();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.green : Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showPopup(success: false, message: 'Email & Password harus diisi');
      return;
    }

    try {
      // cek admin manual
      if (email == 'admin@gmail.com' && password == '123456') {
        _showPopup(
          success: true,
          message: 'Selamat datang kembali, ',
          boldText: 'Administrator',
          onOk: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          },
        );
        return;
      }

      // login normal untuk user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc =
          await _firestore.collection('users').doc(userCredential.user!.uid).get();
      final fullName = doc['name'] ?? 'Pengguna';

      _showPopup(
        success: true,
        message: 'Selamat datang kembali, ',
        boldText: fullName,
        onOk: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Email atau password salah';
      if (e.code == 'user-not-found') errorMsg = 'User tidak ditemukan';
      if (e.code == 'wrong-password') errorMsg = 'Password salah';
      _showPopup(success: false, message: errorMsg);
    } catch (e) {
      _showPopup(success: false, message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_rounded,
                  size: 90, color: Colors.lightBlueAccent),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk untuk melanjutkan',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined,
                              color: Colors.lightBlue),
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Colors.lightBlue),
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'MASUK',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Belum punya akun? Daftar sekarang',
                          style: TextStyle(color: Colors.lightBlueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
