import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobar_app/Screens/createJobScreen.dart';
import 'package:jobar_app/Screens/jobDetailsScreen.dart';
import 'package:jobar_app/Screens/loginscreen.dart';

// Import the placeholder screens we just made
// <-- Update your package name

// Import your login screen to navigate back
 // <-- Update your package name

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This tracks which tab is currently selected
  int _selectedIndex = 0;

  // This list holds the widgets for each tab
  static const List<Widget> _tabScreens = <Widget>[
    AvailableJobsTab(), // Our first tab
    MyPostingsTab(),    // Our second tab
  ];

  // This list holds the titles for the AppBar
  static const List<String> _tabTitles = <String>[
    'Available Jobs',
    'My Job Postings',
  ];

  // This function is called when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This function navigates to the Create Job screen
  void _navigateToCreateJob(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const CreateJobScreen()),
    );
  }

  // This function logs the user out and returns to the Login screen
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Go back to Login and remove all other screens from history
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const LoginScreen()),
        (Route<dynamic> route) => false, // This removes everything
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title changes based on the selected tab
        title: Text(_tabTitles[_selectedIndex]),
        backgroundColor: Colors.green, // Matching your style
        actions: [
          // Add a logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        // Display the correct screen from our list
        child: _tabScreens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'All Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_outlined),
            label: 'My Postings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green, // Matching your style
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateJob(context),
        backgroundColor: Colors.green,
        tooltip: 'Post a Job',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- TAB 1: AVAILABLE JOBS ---

class AvailableJobsTab extends StatelessWidget {
  const AvailableJobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Listen to ALL jobs, ordered by when they were posted (newest first)
      stream: FirebaseFirestore.instance
          .collection('jobs') .orderBy('datePosted', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No jobs posted yet.'));
        }

        final jobDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: jobDocs.length,
          itemBuilder: (context, index) {
            final jobData = jobDocs[index].data() as Map<String, dynamic>;
            final jobId = jobDocs[index].id;

            return ListTile(
              
              title: Text(jobData['title'] ?? 'No Title'),
              subtitle: Text(jobData['location'] ?? 'No Location'),
              trailing: Text(jobData['pay'] ?? 'No Pay'),
              onTap: () {
                // Navigate to the details screen when tapped
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => JobDetailsScreen(jobId: jobId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// --- TAB 2: MY POSTINGS ---

class MyPostingsTab extends StatelessWidget {
  const MyPostingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // This should theoretically never happen if they're on this screen
      return const Center(child: Text('Please log in.'));
    }

    return StreamBuilder<QuerySnapshot>(
      // Listen to jobs BUT...
      stream: FirebaseFirestore.instance
          .collection('jobs')
          // ...filter to ONLY show jobs where 'postedBy' matches our user's ID
          .where('postedBy', isEqualTo: user.uid)
          .orderBy('datePosted', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("You haven't posted any jobs yet."));
        }

        final jobDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: jobDocs.length,
          itemBuilder: (context, index) {
            final jobData = jobDocs[index].data() as Map<String, dynamic>;
            final jobId = jobDocs[index].id;

            return ListTile(
              title: Text(jobData['title'] ?? 'No Title'),
              subtitle: Text(jobData['location'] ?? 'No Location'),
              // We'll add edit/delete buttons here later
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => JobDetailsScreen(jobId: jobId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}