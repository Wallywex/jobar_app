import 'package:flutter/material.dart';

class CreateJobScreen extends StatelessWidget {
  const CreateJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Job'),
      ),
      body: const Center(
        child: Text('Job Creation Form will be here.'),
      ),
    );
  }
}