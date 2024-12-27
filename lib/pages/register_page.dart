import 'package:flutter/material.dart';
import 'package:inventory_system/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Get auth service
  final authService = AuthService();

  // text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Password visibility toggle
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // SignUp button pressed
  void signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // check that password is match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }

    // attempt signUp...
    try {
      await authService.signUpWithEmailPassword(email, password);

      // pop this register page
      Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
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
                "Sign Up",
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Membuat teks tebal
                  fontSize: 50, // Ukuran teks lebih besar
                ),
              ),

              const SizedBox(height: 20,), // Spacing

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

              // confirm password
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible, // Menyembunyikan teks
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock), // Ikon kunci
                  border: const OutlineInputBorder(), // Border pada field
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible; // Toggle visibility
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
                  onPressed: signUp, 
                  child: const Text("Sign Up"),
                ),
              ),

              const SizedBox(height: 12,), // Spacing

              // Go to login page
              GestureDetector(
                onTap: () => Navigator.pop(context), // Navigate back to login page
                child: const Center(
                  child: Text(
                    "Already have an account? Login",
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
