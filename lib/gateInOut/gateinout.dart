import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrcodedataextraction/getout/gateoutpage.dart';
import 'package:qrcodedataextraction/homepage/homepage.dart';
import 'package:qrcodedataextraction/loginpage/loginpage.dart';

import 'dart:ui';

class GateSelectionPage extends StatelessWidget {
  const GateSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to help with scaling
    final size = MediaQuery.of(context).size;
    final isVerySmall = size.height < 600; 

    return Scaffold(
      body: Stack(
        children: [
          // --- Layer 1: Background Image ---
          Positioned.fill(
            child: Image.asset(
              'assets/bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // --- Layer 2: Dark Overlay ---
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),

          // --- Layer 3: Main Content ---
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Header Section ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome Admin",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12, // Reduced font
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "GATE CONTROL",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18, // Reduced font
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                // Logout Button (Compact)
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.power_settings_new, color: Colors.orangeAccent, size: 20),
                                    tooltip: "Logout",
                                    onPressed: () => _showLogoutDialog(context),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // --- Center Action Cards ---
                            // Used Expanded to center the group, but removed Expanded from children to keep them small
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // GATE IN CARD
                                  _buildGlassCard(
                                    title: "ENTRY",
                                    subtitle: "Gate In Scan",
                                    assetPath: 'assets/gatein.png',
                                    color: const Color(0xFF4CAF50), // Green
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const HomePage()),
                                      );
                                    },
                                  ),
                                  
                                  const SizedBox(height: 15), // Gap between buttons

                                  // GATE OUT CARD
                                  _buildGlassCard(
                                    title: "EXIT",
                                    subtitle: "Gate Out Scan",
                                    assetPath: 'assets/gateout.png',
                                    color: const Color(0xFFFF5252), // Red/Orange
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const GateOut()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            // --- Footer ---
                            Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.qr_code_scanner, color: Colors.white24, size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    "TagTrackr System v1.0",
                                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.logout_rounded, size: 30, color: Color(0xFFFF6F3C)),
                    const SizedBox(height: 15),
                    const Text("Logging Out?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      "Are you sure you want to exit?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await GetStorage().erase();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                  (route) => false,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6F3C)),
                            child: const Text("Logout", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Pro Glassmorphism Card Widget ---
  Widget _buildGlassCard({
    required String title,
    required String subtitle,
    required String assetPath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // Slightly smaller radius
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            highlightColor: color.withOpacity(0.1),
            splashColor: color.withOpacity(0.2),
            child: Container(
              height: 80, // <--- Fixed Small Height (Chota Button)
              width: double.infinity, 
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row( 
                children: [
                  // Icon Section
                  Container(
                    height: 45, // Smaller Icon Box
                    width: 45,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
                      ],
                    ),
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.directions_car, color: Colors.white, size: 20);
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 15),

                  // Text Info
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Smaller Title
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11, // Smaller Subtitle
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Arrow Icon to indicate action
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 16)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}