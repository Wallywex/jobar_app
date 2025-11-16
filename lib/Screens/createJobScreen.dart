// --- NEW IMPORTS ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ---------------------
import 'package:flutter/material.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  // --- 1. ADD THE FORM KEY AND LOADING STATE ---
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- 2. ADD TEXT EDITING CONTROLLERS ---
  final _titleController = TextEditingController();
  final _payController = TextEditingController(); // Renamed from 'budget'
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // --- 3. THE FUNCTION THAT DOES THE WORK ---
  Future<void> _postJob() async {
    // First, validate the form
    final isValid = _formKey.currentState?.validate();
    if (isValid == null || !isValid) {
      return; // Stop if form is invalid
    }

    // Get the current user (we MUST know who is posting)
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // This should never happen if they're on this screen, but just in case
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      return;
    }

    // Set loading state
    setState(() => _isLoading = true);

    try {
      // --- 4. CREATE THE JOB DATA ---
      // This is a Map, which is how Firestore stores data (like JSON)
      final Map<String, dynamic> jobData = {
        'title': _titleController.text.trim(),
        'pay': _payController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        // --- CRITICAL FIELDS ---
        'postedBy': user.uid, // This links the job to the user!
        'datePosted': Timestamp.now(), // So we can sort by newest
      };

      // --- 5. SAVE TO FIRESTORE ---
      // Go to the 'jobs' collection and add a new document
      await FirebaseFirestore.instance.collection('jobs').add(jobData);

      // If we get here, it worked!
      if (mounted) {
        // Close this screen and go back to the HomeScreen
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle any errors
      print("Error posting job: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting job: $e')),
        );
      }
    }

    // Always turn off loading, even if it fails
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // --- 6. CLEAN UP CONTROLLERS ---
  @override
  void dispose() {
    _titleController.dispose();
    _payController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload a new job")),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        // --- 7. CONNECT THE FORM KEY ---
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Column(
                children: [
                  TextFormField(
                    // --- 8. CONNECT CONTROLLER & VALIDATOR ---
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a job title.';
                      }
                      return null;
                    },
                    // (Your beautiful styling)
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Type job title here..",
                      labelText: "Job Title",
                      // ... rest of your style
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                      hintStyle:
                          const TextStyle(fontSize: 18, color: Colors.black),
                      suffixIcon:
                          const Icon(Icons.work_outline, color: Colors.green),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade900, width: 3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade900, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    // --- 8. CONNECT CONTROLLER & VALIDATOR ---
                    controller: _payController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the pay/budget.';
                      }
                      return null;
                    },
                    // (Your beautiful styling)
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Type payment here..",
                      labelText: "Budget",
                      // ... rest of your style
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                      hintStyle:
                          const TextStyle(fontSize: 18, color: Colors.black),
                      suffixIcon:
                          const Icon(Icons.attach_money, color: Colors.green),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade900, width: 3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade900, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    // --- 8. CONNECT CONTROLLER & VALIDATOR ---
                    controller: _locationController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a location.';
                      }
                      return null;
                    },
                    // (Your beautiful styling)
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Type location here..",
                      labelText: "Location",
                      // ... rest of your style
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                      hintStyle:
                          const TextStyle(fontSize: 18, color: Colors.black),
                      suffixIcon:
                          const Icon(Icons.location_on, color: Colors.green),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade900, width: 3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade900, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    // --- 8. CONNECT CONTROLLER & VALIDATOR ---
                    controller: _descriptionController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description.';
                      }
                      return null;
                    },
                    maxLength: 100, // You can change/remove this
                    maxLines: 5,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Type full description here..",
                      // ... rest of your style
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                      hintStyle:
                          const TextStyle(fontSize: 18, color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade900, width: 3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade900, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    // --- 9. CONNECT ONPRESSED AND LOADING STATE ---
                    onPressed: _isLoading ? null : _postJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Post Job"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
