import 'package:flutter/material.dart';
import 'package:qrcodedataextraction/loginpage/logincontroller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // UI Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Logic Controller
  final LoginController _loginController = LoginController();
  
  // UI State
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Wrapper function to connect UI to Controller
  void _onLoginPressed() {
    _loginController.handleLogin(
      context: context,
      username: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      setLoading: (bool loading) {
        if (mounted) {
          setState(() {
            _isLoading = loading;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // --- Background ---
          Positioned.fill(
            child: Image.asset('assets/Inner-bg.jpg', fit: BoxFit.cover),
          ),

          // --- Form Content ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_open_rounded, size: 50, color: Color(0xFFFF6F3C)),
                    const SizedBox(height: 10),
                    const Text('Welcome Back', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                    Text('Login to Continue', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    const SizedBox(height: 25),

                    // User ID Field
                    _buildTextField(
                      controller: _emailController,
                      label: 'User ID',
                      icon: Icons.person_outline,
                      width: screenWidth > 320 ? 280 : screenWidth * 0.85,
                    ),
                    const SizedBox(height: 12),

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      width: screenWidth > 320 ? 280 : screenWidth * 0.85,
                    ),
                    const SizedBox(height: 25),

                    // Login Button
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F3C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to keep code clean
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double width,
    bool isPassword = false,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFFFF6F3C)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[600]),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          isDense: true,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6F3C), width: 2)),
        ),
      ),
    );
  }
}