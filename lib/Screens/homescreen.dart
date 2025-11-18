import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jobar_app/Screens/createJobScreen.dart';
import 'package:jobar_app/Screens/jobDetailsScreen.dart';
import 'package:jobar_app/Screens/loginscreen.dart';
import 'package:jobar_app/Widgets/emptyStateWidget.dart';
import 'package:jobar_app/Widgets/jobCard.dart';

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
    MyPostingsTab(), // Our second tab
  ];

  // This list holds the titles for the AppBar
  static const List<String> _tabTitles = <String>[
    'Available Jobs',
    'My Job Postings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToCreateJob(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => const CreateJobScreen()));
  }


  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const LoginScreen()),
        (Route<dynamic> route) => false, 
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tabTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        // --- 2. STYLING ---
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 40,
              color: Colors.green,
            ),
            tooltip: 'Profile',
            onPressed: () {
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile screen coming soon!')),
              );
            },
          ),

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



class MyPostingsTab extends StatelessWidget {
  const MyPostingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in.'));
    }

    
    
    return Column(
      children: [
        
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('jobs')
                .where('postedBy', isEqualTo: user.uid)
                .orderBy('datePosted', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SpinKitFadingCube(color: Colors.purple, size: 50.0),
                );
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong.'));
              }

              // --- 3. THIS IS THE CRITICAL CHECK ---
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // Now this EmptyStateWidget will fill the 'Expanded' space
                return const EmptyStateWidget(
                  icon: Icons.work_off_outlined,
                  message: "You haven't posted any jobs yet.",
                );
              }

              
              final jobDocs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: jobDocs.length,
                itemBuilder: (context, index) {
                  final jobData = jobDocs[index].data() as Map<String, dynamic>;
                  final jobId = jobDocs[index].id;

                 
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => JobDetailsScreen(jobId: jobId),
                            ),
                          );
                        },
                        child: Jobcard(jobData: jobData),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteDialog(context, jobId);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
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
          ),
        ),
      ],
    );
  }

  

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
                
                await FirebaseFirestore.instance
                    .collection('jobs')
                    .doc(jobId)
                    .delete();

                
                Navigator.of(ctx).pop();

                
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
