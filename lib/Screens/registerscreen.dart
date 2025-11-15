import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// THIS IS THE ENTIRE REPLACEMENT for your old state class
class _RegisterScreenState extends State<RegisterScreen> {
  // 1. We add a Form Key to track the validation state.
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  // We add a loading state
  bool _isLoading = false;

  Future<void> _signUp() async {
    // 2. We check if the form is valid *before* doing anything.
    final isValid = _formKey.currentState?.validate();
    if (isValid == null || !isValid) {
      return; // Stop if validation fails
    }

    // 3. Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      _showSuccessDialog(); // Call our success dialog

    } on FirebaseAuthException catch (e) {
      // 4. This is our new, smarter error handling
      String errorMessage = 'An unknown error occurred.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password you provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'This email address is already in use.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      }
      
      _showErrorDialog(errorMessage);

    } catch (e) {
      // Catch any other general errors
      _showErrorDialog('An unknown error occurred.');
    }

    // 5. Always turn off loading, even if we fail
    setState(() {
      _isLoading = false;
    });
  }

  // The success dialog you wanted
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(dialogContext).pop(); // Close dialog
          Navigator.of(context).pop();      // Close register screen
        });
        return const AlertDialog(
          title: Text('Success!'),
          content: Text('Registration successful. Redirecting to login...'),
        );
      },
    );
  }

  // Our reusable error dialog
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registration Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers!
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      // 6. We wrap our form fields in a Form widget
      body: Form(
        key: _formKey, // Connect the key
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                // 7. This is the validation logic
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email.';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                     return 'Please enter a valid email address.';
                  }
                  return null; // null means it's valid
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                // 8. This is the validation logic
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your password.';
                  }
                  if (value.trim().length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null; // null means it's valid
                },
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _isLoading ? null : _signUp, // Disable button when loading
                child: Container(
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey : Colors.green, // Change color when loading
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: 400,
                  height: 60,
                  child: Center(
                    // 9. Show a spinner or text
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "REGISTER",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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