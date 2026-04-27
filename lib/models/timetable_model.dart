class TimetableClass {
  final String id;
  final String name;
  final String type; // 'Theory' or 'Lab'
  final String startTime;
  final String endTime;
  final String room;
  final String instructor;
  final int semester;
  final int dayNumber; // 1-7

  TimetableClass({
    required this.id,
    required this.name,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.instructor,
    required this.semester,
    required this.dayNumber,
  });

  factory TimetableClass.fromFirestore(Map<String, dynamic> data, String id) {
    return TimetableClass(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'Theory',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      room: data['room'] ?? '',
      instructor: data['instructor'] ?? '',
      semester: data['semester'] ?? 1,
      dayNumber: data['dayNumber'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'instructor': instructor,
      'semester': semester,
      'dayNumber': dayNumber,
    };
  }
}
