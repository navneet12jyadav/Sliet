import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mess_menu.dart';

// Helper function to get today's day (e.g., "wednesday")
String getTodayDay() {
  const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  return days[DateTime.now().weekday - 1]; 
}

// Riverpod provider that listens to Firestore in real-time
final messMenuProvider = StreamProvider<MessMenu?>((ref) {
  final today = getTodayDay();
  
  return FirebaseFirestore.instance
      .collection('mess_menus')
      .doc(today)
      .snapshots() // snapshots() makes it real-time!
      .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return MessMenu.fromFirestore(snapshot.data()!);
        }
        return null;
      });
});