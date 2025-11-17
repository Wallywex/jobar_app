import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobar_app/Widgets/buildTextField.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _payController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  Future<void> _postJob() async {
    final _isValid = _formKey.currentState?.validate();
    if (_isValid == null || !_isValid) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You must be logged in to post")));
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> jobData = {
        'title': _titleController.text.trim(),
        'pay': _payController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'contactPhone': _contactPhoneController.text.trim(),
        'postedBy': user.uid,
        'datePosted': Timestamp.now(),
      };
      await FirebaseFirestore.instance.collection('jobs').add(jobData);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error Posting Job : $e");

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error Posting Job : $e")));
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _payController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text(
          "Post a New Job",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // JOB TITLE
                Buildtextfield(
                  controller: _titleController,
                  hint: 'e.g Driver for a Day',
                  icon: Icons.work_outline,
                  label: 'Job Title',

                  maxLines: 1,
                  keyBoard: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a job title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // PAY
                Buildtextfield(
                  controller: _payController,
                  hint: 'e.g ₦15000',
                  icon: Icons.attach_money_outlined,
                  label: 'Pay',

                  maxLines: 1,
                  keyBoard: TextInputType.numberWithOptions(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the pay';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Location
                Buildtextfield(
                  controller: _locationController,
                  hint: 'e.g Lekki Phase 1',
                  icon: Icons.location_on_outlined,
                  label: 'Location',

                  maxLines: 1,
                  keyBoard: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a job title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Buildtextfield(
                  controller: _contactPhoneController,
                  hint: 'e.g +234 816 792 5941',
                  icon: Icons.phone,
                  label: 'Contact Phone',

                  maxLines: 1,
                  keyBoard: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a contact Phone';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Buildtextfield(
                  controller: _descriptionController,
                  hint:
                      'Describe the job requirements, responsibilities, and any other important details...',
                  icon: Icons.description_outlined,
                  label: 'Full Description',

                  maxLines: 5,
                  keyBoard: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a job description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _postJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12)
                    ),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  child: _isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: SpinKitCircle(
                      color: Colors.white,
                      size: 24,
                    ) 
                    ,
                  )
                  : Text('Post Job')
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
