// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcodedataextraction/gateInOut/gateinout.dart';
import 'package:qrcodedataextraction/homepage/homepage.dart';
import 'package:qrcodedataextraction/loginpage/loginpage.dart';
import 'package:qrcodedataextraction/splashscreen/spalshcontroller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashControllerProvider, (previous, next) {
      next.whenData((isLoggedIn) {
        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GateSelectionPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/logo.png',
        height: 120,
      ),
      const SizedBox(height: 16),
    ],
  ),
),

    );
  }
}
