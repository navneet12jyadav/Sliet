import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mess_menu.dart';
import '../models/timetable_model.dart';
import '../models/holiday_model.dart';
import '../models/bus_schedule_model.dart';
import '../models/notification_model.dart';
import '../models/hostel_mess_model.dart';

// Helper function to get today's day (e.g., "wednesday")
String getTodayDay() {
  const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  return days[DateTime.now().weekday - 1];
}

// Legacy mess menu provider (real-time Firestore stream)
final messMenuProvider = StreamProvider<MessMenu?>((ref) {
  final today = getTodayDay();
  return FirebaseFirestore.instance
      .collection('mess_menus')
      .doc(today)
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return MessMenu.fromFirestore(snapshot.data()!);
        }
        return null;
      });
});

// Timetable classes for a specific day number (1-7)
final timetableForDayProvider = StreamProvider.family<List<TimetableClass>, int>((ref, dayNumber) {
  return FirebaseFirestore.instance
      .collection('timetable')
      .where('dayNumber', isEqualTo: dayNumber)
      .orderBy('startTime')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TimetableClass.fromFirestore(doc.data(), doc.id))
          .toList());
});

// All holidays
final holidaysProvider = StreamProvider<List<Holiday>>((ref) {
  return FirebaseFirestore.instance
      .collection('holidays')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Holiday.fromFirestore(doc.data(), doc.id))
          .toList());
});

// Bus schedules
final busSchedulesProvider = StreamProvider<List<BusStop>>((ref) {
  return FirebaseFirestore.instance
      .collection('busSchedules')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BusStop.fromFirestore(doc.data(), doc.id))
          .toList());
});

// Notifications for current user
final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('studentId', whereIn: [user.uid, 'all'])
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc.data(), doc.id))
          .toList());
});

// Unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.when(
    data: (list) => list.where((n) => !n.read).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Hostel mess for specific hostel
final hostelMessProvider = StreamProvider.family<HostelMess?, String>((ref, hostelId) {
  if (hostelId.isEmpty) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('mess')
      .doc(hostelId)
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return HostelMess.fromFirestore(snapshot.data()!, snapshot.id);
        }
        return null;
      });
});
