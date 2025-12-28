import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
// TODO: Pastikan 'myapp' sesuai dengan nama proyek Anda, misalnya 'kibas'
import 'package:myapp/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 7),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E497),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ornamen di pojok kiri atas
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/ornament.png',
              width: 250, // DIUBAH: Ukuran ornamen diperbesar
            ),
          ),
          // Ornamen di pojok kanan bawah (diputar)
          Positioned(
            bottom: 0,
            right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateZ(math.pi),
              child: Image.asset(
                'assets/images/ornament.png',
                width: 250, // DIUBAH: Ukuran ornamen diperbesar
              ),
            ),
          ),
          // Konten utama di tengah
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 700, // DIUBAH: Ukuran logo diperbesar
                ),
                
              ],
            ),
          ),
          // Bar gelap di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 25,
              color: const Color(0xFF3D3A3A).withOpacity(0.85),
            ),
          ),
          // Bar gelap di bagian bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 25,
              color: const Color(0xFF3D3A3A).withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}