import 'package:flutter/material.dart';
import 'dart:async';

import 'package:personality_score/screens/home_desktop_layout/desktop_layout.dart'; // Für Timer

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Beispiel: Warte 2 Sekunden und navigiere dann weiter
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DesktopLayout()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8DB),
      body: Center(
        // Zeige dein Bild aus dem assets-Ordner
        child: Image.asset(
          'assets/wasserzeichen.webp',
          width: MediaQuery.of(context).size.width * 0.4,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
