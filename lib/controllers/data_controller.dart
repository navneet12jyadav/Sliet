import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mess_menu.dart';
import '../models/timetable_model.dart';
import '../models/bus_schedule_model.dart';

// Helper function to get today's day name (e.g., "wednesday")
String getTodayDay() {
  const days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  return days[DateTime.now().weekday - 1];
}

// ---------------------------------------------------------------------------
// Mess Menu Providers
// ---------------------------------------------------------------------------

/// Global mess menu (legacy / fallback) – keyed by day of week.
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

/// Hostel-specific mess menu provider.
/// Doc ID format: "{hostelId}_{dayOfWeek}" e.g. "BH-1_monday"
/// Falls back to a global doc keyed by just the day when hostelId is empty.
final hostelMessMenuProvider =
    StreamProvider.family<MessMenu?, String>((ref, hostelId) {
  final today = getTodayDay();
  // If no hostelId is provided, look up the global menu doc (legacy format).
  final docId = hostelId.isEmpty ? today : '${hostelId}_$today';
  return FirebaseFirestore.instance
      .collection('mess_menus')
      .doc(docId)
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return MessMenu.fromFirestore(snapshot.data()!);
        }
        return null;
      });
});

// ---------------------------------------------------------------------------
// Timetable Providers
// ---------------------------------------------------------------------------

/// Real-time stream of the timetable cycle configuration.
final timetableConfigProvider = StreamProvider<TimetableConfig?>((ref) {
  return FirebaseFirestore.instance
      .collection('timetable_config')
      .doc('config')
      .snapshots()
      .map(
        (snap) =>
            snap.exists ? TimetableConfig.fromFirestore(snap.data()!) : null,
      );
});

/// Real-time stream of classes for a specific cyclic day number.
final timetableDayProvider =
    StreamProvider.family<TimetableDay?, int>((ref, dayNumber) {
  return FirebaseFirestore.instance
      .collection('timetable')
      .doc('day_$dayNumber')
      .snapshots()
      .map(
        (snap) =>
            snap.exists ? TimetableDay.fromFirestore(snap.data()!) : null,
      );
});

// ---------------------------------------------------------------------------
// Bus Schedule Provider
// ---------------------------------------------------------------------------

/// Real-time stream of all bus routes and their timings.
final busScheduleProvider = StreamProvider<List<BusRoute>>((ref) {
  return FirebaseFirestore.instance
      .collection('bus_schedules')
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((doc) => BusRoute.fromFirestore(doc)).toList(),
      );
});