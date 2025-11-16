import 'package:flutter/material.dart';
import 'package:jobar_app/Widgets/buildInfoRow.dart';

class Jobcard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  const Jobcard({super.key, required this.jobData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1.0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jobData['title'] ?? 'No Title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Pay row
            BuildInfoRow(
              icon: Icons.attach_money,
              iconColor: Colors.green,
              text: '₦${jobData['pay'] ?? 'Not specified'}',
            ),
            const SizedBox(height: 8),
            // Location Row
            BuildInfoRow(
              icon: Icons.location_on,
              iconColor: Colors.grey.shade600,
              text: jobData['location'],
            ),
          ],
        ),
      ),
    );
  }
}
