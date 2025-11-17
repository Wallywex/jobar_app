import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Add Form Key and loading state
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 2. Add new controllers for Name and Confirm Password
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false; // For the eye icon

  Future<void> _signUp() async {
    // 3. Validate the form first
    final isValid = _formKey.currentState?.validate();
    if (isValid == null || !isValid) {
      return; // Stop if validation fails
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 4. Create the user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 5. Update their profile with the name
      // This is a separate step after creation
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(
          _nameController.text.trim(),
        );
      }

      // 6. Show success and navigate
      if (mounted) {
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      // 7. Handle errors
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
      _showErrorDialog('An unknown error occurred.');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // The success dialog you wanted
  // The success dialog you wanted
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User can't click away
      builder: (dialogContext) {
        // The 3-second timer is the same
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(dialogContext).pop(); // Close dialog
          Navigator.of(context).pop(); // Close register screen
        });

        // --- THIS IS THE NEW UI ---
        return Dialog(
          // Give it the same rounded corners as your form
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Keeps the dialog compact
              children: [
                // 1. The Green Checkmark
                const Icon(
                  Icons.check_circle_outline, // Or Icons.check_circle
                  color: Colors.green,
                  size: 80, // Make it big
                ),
                const SizedBox(height: 20),

                // 2. "Registration successful"
                const Text(
                  'Registration successful',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // 3. "Redirecting to login..."
                Text(
                  'Redirecting to login...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Our reusable error dialog
  // Our reusable error dialog
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        // Use the same rounded shape
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Keep it compact
            children: [
              // 1. The Red Error Icon
              const Icon(
                Icons.error_outline, // A clear "error" icon
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 20),

              // 2. The Title
              const Text(
                'Registration Error',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // 3. The error message
              Text(
                message, // This is the message from Firebase
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // 4. The "OK" button to dismiss
              SizedBox(
                width: double.infinity, // Make the button wide
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Just close the dialog
                  },
                  // Style it to match your "Create Account" button
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Purple
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- NEW BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Light purple background from your design
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('lib/Images/Logo.png', height: 250, width: 250),
                // 2. "Sign up" Title
                const Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // 3. "Already have an account?" Text
                Row(
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        // Go back to the login screen
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.green, // Purple
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. The Form in a white card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Name Field ---
                        _buildFormLabel('Name'),
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration(
                            hint: 'Enter your name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- Email Field ---
                        _buildFormLabel('Email'),
                        TextFormField(
                          controller: _emailController,
                          decoration: _buildInputDecoration(
                            hint: 'Enter your email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email.';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- Password Field ---
                        _buildFormLabel('Password'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _buildInputDecoration(
                            hint: '8 - 12 characters',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a password.';
                            }
                            if (value.trim().length < 8) {
                              return 'Password must be at least 8 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- Confirm Password Field (User Request) ---
                        _buildFormLabel('Confirm Password'),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _buildInputDecoration(
                            hint: 'Re-enter your password',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please confirm your password.';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 5. "Create Account" Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Purple
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          
                          child: SpinKitCircle(color: Colors.green, size: 24),
                        )
                      : const Text("Create Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER for the form field labels ---
  Widget _buildFormLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // --- HELPER for InputDecoration ---
  InputDecoration _buildInputDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      suffixIcon: suffixIcon,
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 12.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: 0.0,
        ), // Almost invisible
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.0,
        ), // Light grey border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Color(0xFF8E24AA),
          width: 2,
        ), // Purple border
      ),
    );
  }
}
