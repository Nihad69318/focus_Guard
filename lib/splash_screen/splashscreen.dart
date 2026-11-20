import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_guard/screens/Home_Screen.dart';
import 'package:focus_guard/screens/LoginScreen.dart';
import 'package:go_router/go_router.dart';

import '../app/color/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    // Splash screen কিছুক্ষণ দেখানোর জন্য
    await Future.delayed(const Duration(seconds: 5));

    // Firebase থেকে আসল login status জেনে নাও
    final user = await FirebaseAuth.instance.authStateChanges().first;

    if (!mounted) return;

    if (user != null) {
      // আগে থেকে login করা থাকলে সরাসরি Home
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    } else {
      // নতুন ইউজার বা logout করা ইউজার হলে Login screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 65,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Focus guard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Protect Your Focus. Take Control.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 35),
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}