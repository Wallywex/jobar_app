// --- NEW IMPORTS ---
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// ---------------------
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    _jobFuture = FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .get();
  }

  // --- NEW FUNCTION: To launch the phone dialer ---
  Future<void> _launchCaller(String phoneNumber) async {
    // Create a 'tel:' URL
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    // Ask the phone to launch this URL
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Show an error if it fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make the call.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // A light background
      body: FutureBuilder<DocumentSnapshot>(
        future: _jobFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Job not found.'));
          }

          // --- SUCCESS: We have the data ---
          final jobData = snapshot.data!.data() as Map<String, dynamic>;

          // Extract all our data with fallbacks
          final title = jobData['title'] ?? 'No Title';
          final pay = jobData['pay'] ?? 'Not specified';
          final location = jobData['location'] ?? 'Not specified';
          final description = jobData['description'] ?? 'No description';
          final contactPhone = jobData['contactPhone'] ?? '';
          
          // Format the date
          final datePosted = (jobData['datePosted'] as Timestamp).toDate();
          final formattedDate = DateFormat('M/d/yyyy').format(datePosted);

          return CustomScrollView(
            slivers: [
              // --- 1. The AppBar ---
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 1,
                title: Text(
                  title,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // --- 2. The Body Content ---
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- Pay ---
                          Text(
                            '₦$pay', // Added the ₦ prefix
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- Location Card ---
                          _buildInfoCard(
                            child: _buildInfoRow(
                              icon: Icons.location_on_outlined,
                              text: location,
                              iconColor: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // --- Job Description Card ---
                          _buildInfoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Job Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),

                          // --- Contact Poster Card ---
                          _buildInfoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Contact Poster',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  icon: Icons.phone_outlined,
                                  text: contactPhone,
                                  iconColor: Colors.green.shade700,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- "Call Now" Button ---
                          ElevatedButton.icon(
                            onPressed: contactPhone.isEmpty
                                ? null // Disable button if no number
                                : () => _launchCaller(contactPhone),
                            icon: const Icon(Icons.call, color: Colors.white),
                            label: const Text(
                              'Call Now',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // --- Posted On Date ---
                          Text(
                            'Posted on $formattedDate',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- HELPER for the white cards ---
  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(25.0),
      
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  // --- HELPER for the icon/text rows ---
  Widget _buildInfoRow(
      {required IconData icon, required String text, required Color iconColor}) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded( // Use Expanded to prevent overflow
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
