import 'package:cloud_firestore/cloud_firestore.dart';

class ClassEntry {
  final String subject;
  final String time;
  final String location;
  final String instructor;
  final String type; // 'Theory' or 'Lab'

  ClassEntry({
    required this.subject,
    required this.time,
    required this.location,
    required this.instructor,
    required this.type,
  });

  factory ClassEntry.fromMap(Map<String, dynamic> data) {
    return ClassEntry(
      subject: data['subject'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      instructor: data['instructor'] ?? '',
      type: data['type'] ?? 'Theory',
    );
  }
}

class TimetableDay {
  final int dayNumber;
  final List<ClassEntry> classes;

  TimetableDay({required this.dayNumber, required this.classes});

  factory TimetableDay.fromFirestore(Map<String, dynamic> data) {
    final classList = (data['classes'] as List<dynamic>? ?? [])
        .map((c) => ClassEntry.fromMap(c as Map<String, dynamic>))
        .toList();
    return TimetableDay(
      dayNumber: data['dayNumber'] ?? 1,
      classes: classList,
    );
  }
}

class TimetableConfig {
  final DateTime startDate;
  final int totalDays;
  final List<String> holidays; // ISO date strings: 'YYYY-MM-DD'

  TimetableConfig({
    required this.startDate,
    required this.totalDays,
    required this.holidays,
  });

  factory TimetableConfig.fromFirestore(Map<String, dynamic> data) {
    return TimetableConfig(
      startDate:
          (data['startDate'] as Timestamp?)?.toDate() ?? DateTime(2024, 1, 1),
      totalDays: data['totalDays'] ?? 6,
      holidays: List<String>.from(data['holidays'] ?? []),
    );
  }

  /// Returns the cyclic day number (1-based) for a given date.
  int getCyclicDayFor(DateTime date) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(start).inDays;
    if (diff < 0) return 1;
    return (diff % totalDays) + 1;
  }

  /// Checks whether the given date is a holiday.
  bool isHoliday(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return holidays.contains(dateStr);
  }
}
