// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class Test extends StatefulWidget {
//   const Test({super.key});

//   @override
//   State<Test> createState() => _TestState();
// }

// class _TestState extends State<Test> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _auth = FirebaseAuth.instance;

//   Future<void> _signIn() async {
//     final isValid = _formKey.currentState?.validate();
//     if(isValid == null || !isValid) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _auth.signInWithEmailAndPassword(email: , password: password)
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }