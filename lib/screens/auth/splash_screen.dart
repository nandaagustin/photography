import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sistem_pemesanan_jasa_fotografi/screens/auth/login_screen.dart'; // ubah your_project_name sesuai nama project kamu di pubspec.yaml

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int activeDot = 1; // titik pertama langsung putih

  @override
  void initState() {
    super.initState();

    // animasi titik berubah setiap 600 ms
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        activeDot++;
      });

      if (activeDot > 3) {
        timer.cancel();

        // tunggu sebentar baru pindah ke login
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_rounded,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              "Sistem Pemesanan Jasa Fotografi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            // animasi titik-titik loading
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < activeDot
                        ? Colors.white
                        : Colors.grey[300], // titik aktif putih, sisanya abu
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
