import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrcodedataextraction/data/apiservice.dart';
import 'package:qrcodedataextraction/gateInOut/gateinout.dart';
import 'package:qrcodedataextraction/homepage/homepage.dart';

class LoginController {
  final box = GetStorage();

  // This function handles everything: Validation, API, and Navigation
  Future<void> handleLogin({
    required BuildContext context,
    required String username,
    required String password,
    required Function(bool) setLoading, 
  }) async {
    
    // 1. Hide Keyboard
    FocusScope.of(context).unfocus();

    // 2. Validation
    if (username.isEmpty || password.isEmpty) {
      _showTopSnackBar(context, "Please enter User ID and Password", isError: true);
      return;
    }

    // 3. Start Loading
    setLoading(true);

    try {
      // 4. Call API
      final response = await ApiService.loginUser(username, password);

      // 5. Handle Response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Login Success: $data");
        
        // Save only the "result" value
        box.write("loginResult", data["result"]);
        print("Stored loginResult: ${box.read("loginResult")}");
  _showTopSnackBar(context, "Successfully Logged In", isError: false);

        // Navigate to Homepage
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  GateSelectionPage()),
          );
        }
      } else {
        _showTopSnackBar(context, "Login Failed: Internal Server Error", isError: true);
      }
    } catch (e) {
      print("Login Error: $e");
      _showTopSnackBar(context, "Connection Error: Please check internet", isError: true);
    } finally {
      // 6. Stop Loading
      setLoading(false);
    }
  }

  // --- CUSTOM TOP SNACKBAR FUNCTION ---
  void _showTopSnackBar(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? Colors.redAccent : Colors.green, 
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry?.remove();
    });
  }
}