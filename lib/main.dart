import 'package:flutter/material.dart';
import 'package:jobar_app/Screens/loginscreen.dart';
import 'package:jobar_app/Screens/splashscreen.dart';
import 'package:jobar_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jobar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Splashscreen(), 
      routes: {
        '/login': (context) => const LoginScreen()
      },
    );
  }
}


