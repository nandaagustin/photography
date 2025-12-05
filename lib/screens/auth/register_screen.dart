import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // popup animasi (sudah fix logika teks berhasil/gagal)
  void _showPopup({
    required bool success,
    required String message,
    String? accountName,
  }) {
    _animationController.forward(from: 0.0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
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
                    success ? 'Pendaftaran Berhasil' : 'Pendaftaran Gagal',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // tampilkan pesan berbeda tergantung hasil
                  if (success && accountName != null)
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                        children: [
                          const TextSpan(text: 'Akun '),
                          TextSpan(
                            text: accountName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const TextSpan(text: ' berhasil didaftarkan'),
                        ],
                      ),
                    )
                  else
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      }
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
        ),
      ),
    );
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      _showPopup(success: false, message: 'nama belum diisi');
      return;
    }
    if (email.isEmpty) {
      _showPopup(success: false, message: 'email belum diisi');
      return;
    }
    const domain = '@gmail.com';
    if (!email.toLowerCase().endsWith(domain) ||
        email.length <= domain.length ||
        email.contains(' ')) {
      _showPopup(success: false, message: 'email tidak valid. gunakan alamat gmail yang benar.');
      return;
    }
    if (password.isEmpty) {
      _showPopup(success: false, message: 'password belum diisi');
      return;
    }
    if (password.length < 6) {
      _showPopup(success: false, message: 'password harus minimal 6 karakter');
      return;
    }

    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        _showPopup(success: false, message: 'email sudah terdaftar');
        return;
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showPopup(success: true, message: 'akun berhasil dibuat', accountName: name);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'terjadi kesalahan';
      if (e.code == 'weak-password') {
        errorMessage = 'password terlalu lemah';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'email sudah digunakan';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'format email tidak valid';
      }
      _showPopup(success: false, message: errorMessage);
    } catch (e) {
      _showPopup(success: false, message: 'terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add_alt_1,
                    size: 80,
                    color: Colors.lightBlueAccent,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.lightBlue,
                      ),
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.lightBlue,
                      ),
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.lightBlue,
                      ),
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03A9F4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'DAFTAR',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
