import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jobar_app/Widgets/buildDetailRow.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;
  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Future<DocumentSnapshot> _jobFuture;
  @override
  void initState() {
    super.initState();
    _jobFuture = _fetchJobDetails();
  }

  Future<DocumentSnapshot> _fetchJobDetails() {
    return FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .get();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Details'), backgroundColor: Colors.green),
      body: FutureBuilder(
        future: _jobFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: Could not Load Job'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Job not found'));
          }

          final jobData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jobData['title'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builddetailrow(
                    content: jobData['pay'] ?? 'Not Specified',
                    title: 'pay',
                    icon: Icons.attach_money,
                  ),
                  SizedBox(height: 10),
                  Builddetailrow(
                    content: jobData['location'],
                    title: 'Location',
                    icon: Icons.location_on,
                  ),
                  const Divider(height: 30, thickness: 1),
                  Text(
                    'Full Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    jobData['description'] ?? 'No Description Provided',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
