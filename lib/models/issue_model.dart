import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String id;
  final String authorName;
  final String content;
  final DateTime timestamp;

  Issue({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timestamp,
  });

  // Convert Firestore data into a Dart Object
  factory Issue.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Issue(
      id: doc.id,
      authorName: data['authorName'] ?? 'Anonymous',
      content: data['content'] ?? '',
      // Handle Firebase Timestamps safely
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(), 
    );
  }
}