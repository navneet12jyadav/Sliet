class Holiday {
  final String id;
  final DateTime date;
  final String name;
  final String type; // 'National', 'College', etc.

  Holiday({
    required this.id,
    required this.date,
    required this.name,
    required this.type,
  });

  factory Holiday.fromFirestore(Map<String, dynamic> data, String id) {
    return Holiday(
      id: id,
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      name: data['name'] ?? '',
      type: data['type'] ?? 'National',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date.toIso8601String().substring(0, 10),
      'name': name,
      'type': type,
    };
  }
}
