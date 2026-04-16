import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/notice_model.dart';
import 'package:intl/intl.dart'; // Used for formatting dates nicely

class NoticeBoardScreen extends StatelessWidget {
  const NoticeBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Official Notices', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .orderBy('datePosted', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading notices.'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final notices = snapshot.data!.docs.map((doc) => Notice.fromFirestore(doc)).toList();

          if (notices.isEmpty) {
            return const Center(child: Text('No new notices right now.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              
              // Determine icon and color based on category
              IconData icon = Icons.campaign;
              Color iconColor = Colors.blue;
              if (notice.category == 'Holiday') {
                icon = Icons.celebration;
                iconColor = Colors.green;
              } else if (notice.category == 'Exam') {
                icon = Icons.edit_document;
                iconColor = Colors.red;
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(backgroundColor: iconColor.withOpacity(0.2), child: Icon(icon, color: iconColor)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              notice.title,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(notice.content, style: const TextStyle(fontSize: 14, height: 1.5)),
                      const Divider(height: 24),
                      Text(
                        'Posted: ${DateFormat('MMM dd, yyyy').format(notice.datePosted)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}