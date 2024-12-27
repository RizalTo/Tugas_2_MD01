import 'package:flutter/material.dart';
import 'package:inventory_system/auth/auth_service.dart';
import 'package:inventory_system/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Get auth service
  final authService = AuthService();

  // text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Password visibility toggle
  bool _isPasswordVisible = false;

  // Login button pressed
  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // attempt login...
    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // title
              const Text(
                "Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Membuat teks tebal
                  fontSize: 50, // Ukuran teks lebih besar
                ),
              ),

              const SizedBox(height: 20,),

              // email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress, // Keyboard untuk email
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email), // Ikon email
                  border: OutlineInputBorder(), // Border pada field
                ),
              ),

              const SizedBox(height: 12,),

              // password
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, // Menyembunyikan teks
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock), // Ikon kunci
                  border: const OutlineInputBorder(), // Border pada field
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12,),

              // button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login, 
                  child: const Text("Login"),
                ),
              ),

              const SizedBox(height: 12,),

              // Go to register
               // Link register
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              ),
              child: const Center(
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
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
