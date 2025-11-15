import 'package:flutter/material.dart';

class JobDetailsScreen extends StatelessWidget {
  // We'll need the job ID to fetch details
  final String jobId; 
  const JobDetailsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: Center(
        child: Text('Details for job $jobId will be here.'),
      ),
    );
  }
}