import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobar_app/Screens/createJobScreen.dart';
import 'package:jobar_app/Screens/jobDetailsScreen.dart';
import 'package:jobar_app/Screens/loginscreen.dart';
import 'package:jobar_app/Widgets/emptyStateWidget.dart';
import 'package:jobar_app/Widgets/jobCard.dart';

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
  // --- ADD THIS FUNCTION INSIDE _HomeScreenState ---

  // This tracks which tab is currently selected
  int _selectedIndex = 0;

  // This list holds the widgets for each tab
  static const List<Widget> _tabScreens = <Widget>[
    AvailableJobsTab(), // Our first tab
    MyPostingsTab(), // Our second tab
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => const CreateJobScreen()));
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
  @override
  Widget build(BuildContext context) {
    // We don't need the user name here anymore

    return Scaffold(
      appBar: AppBar(
        // --- 1. CONTEXTUAL TITLE ---
        // This will show "Available Jobs" or "My Job Postings"
        title: Text(
          _tabTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        // --- 2. STYLING ---
        backgroundColor: Colors.white, // Clean, modern look
        foregroundColor: Colors.black, // Makes icons black
        elevation: 0, // Flat design
        // --- 3. UPDATED ACTIONS ---
        actions: [
          // The new Profile Icon
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 40,
              color: Colors.green,
            ),
            tooltip: 'Profile',
            onPressed: () {
              // Later, we can build a ProfileScreen
              // For now, it's a placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile screen coming soon!')),
              );
            },
          ),

          // The existing Logout Icon
          IconButton(
            icon: const Icon(Icons.logout_sharp, size: 30, color: Colors.green),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(child: _tabScreens.elementAt(_selectedIndex)),
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
        // Match your new purple theme
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateJob(context),
        // Match your new purple theme
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
          .collection('jobs')
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
          return const Center(child: Text('No jobs posted yet.'));
        }

        final jobDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: jobDocs.length,
          itemBuilder: (context, index) {
            final jobData = jobDocs[index].data() as Map<String, dynamic>;
            final jobId = jobDocs[index].id;

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => JobDetailsScreen(jobId: jobId),
                  ),
                );
              },
              child: Jobcard(jobData: jobData),
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
          return EmptyStateWidget(icon: Icons.work_off, message: 'You haven\'t posted any jobs yet');
        }

        final jobDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: jobDocs.length,
          // Inside MyPostingsTab -> StreamBuilder -> ListView.builder
          // Inside MyPostingsTab -> StreamBuilder -> ListView.builder
itemBuilder: (context, index) {
  final jobData = jobDocs[index].data() as Map<String, dynamic>;
  final jobId = jobDocs[index].id;

  // We are now using a Stack to overlay the menu
  return Stack(
    children: [
      // 1. The main content (tappable card)
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => JobDetailsScreen(jobId: jobId),
            ),
          );
        },
        child: Jobcard(jobData: jobData), // Your beautiful card
      ),
      
      // 2. The menu button, aligned to the top right
      Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert), // The 3-dot icon
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(context, jobId);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    ],
  );
},
        );
      },
    );
  }

  // --- ADD THIS FUNCTION INSIDE _HomeScreenState ---

  void _showDeleteDialog(BuildContext context, String jobId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This will permanently delete your job posting.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              try {
                // The magic line: Tell Firestore to delete
                await FirebaseFirestore.instance
                    .collection('jobs')
                    .doc(jobId)
                    .delete();

                // Close the dialog
                Navigator.of(ctx).pop();

                // Show a success message (optional, but good)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Job deleted successfully.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Handle any errors
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete job: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
