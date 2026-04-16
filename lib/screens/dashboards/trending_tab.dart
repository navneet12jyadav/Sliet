import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/issue_model.dart';
import '../../controllers/auth_controller.dart';

class TrendingTab extends ConsumerStatefulWidget {
  const TrendingTab({super.key});

  @override
  ConsumerState<TrendingTab> createState() => _TrendingTabState();
}

class _TrendingTabState extends ConsumerState<TrendingTab> {
  final TextEditingController _postController = TextEditingController();

  // Function to save a new post to Firestore
  void _submitPost(String userName) async {
    if (_postController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('trending_issues').add({
      'authorName': userName,
      'content': _postController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _postController.clear();
    Navigator.pop(context); // Close the popup
  }

  // Popup dialog to write a post
  void _showPostDialog(String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Campus Update', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _postController,
            maxLength: 100, // Enforcing your 100-character limit!
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'What is happening on campus?',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => _submitPost(userName),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user so we can attach their name to the post
    final userAsync = ref.watch(userDataProvider);

    return Scaffold(
      // Real-time listener for posts, ordered by newest first
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trending_issues')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final issues = snapshot.data!.docs.map((doc) => Issue.fromFirestore(doc)).toList();

          if (issues.isEmpty) {
            return const Center(child: Text('No campus updates yet. Be the first!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issue.authorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      const SizedBox(height: 8),
                      Text(issue.content, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // The floating + button
      floatingActionButton: userAsync.when(
        data: (user) => FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          onPressed: () => _showPostDialog(user?.name ?? 'Anonymous'),
          child: const Icon(Icons.add),
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}