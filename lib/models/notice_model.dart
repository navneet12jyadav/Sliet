import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String title;
  final String content;
  final String category; // e.g., "Holiday", "Exam", "General"
  final DateTime datePosted;

  Notice({
    required this.title,
    required this.content,
    required this.category,
    required this.datePosted,
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Notice(
      title: data['title'] ?? 'No Title',
      content: data['content'] ?? '',
      category: data['category'] ?? 'General',
      datePosted: (data['datePosted'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}