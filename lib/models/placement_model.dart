import 'package:cloud_firestore/cloud_firestore.dart';

class PlacementInsight {
  final String alumniName;
  final String company;
  final String role;
  final String batch;
  final String advice;

  PlacementInsight({
    required this.alumniName,
    required this.company,
    required this.role,
    required this.batch,
    required this.advice,
  });

  factory PlacementInsight.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PlacementInsight(
      alumniName: data['alumniName'] ?? 'Anonymous',
      company: data['company'] ?? 'Unknown Company',
      role: data['role'] ?? 'Trainee',
      batch: data['batch'] ?? '2025',
      advice: data['advice'] ?? 'Keep coding!',
    );
  }
}