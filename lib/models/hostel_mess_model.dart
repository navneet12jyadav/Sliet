class MealItem {
  final String type; // Breakfast, Lunch, Dinner
  final String startTime;
  final String endTime;
  final List<String> items;

  MealItem({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.items,
  });

  factory MealItem.fromMap(Map<String, dynamic> data) {
    return MealItem(
      type: data['type'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      items: List<String>.from(data['items'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'items': items,
    };
  }
}

class DayMenu {
  final String date; // YYYY-MM-DD
  final List<MealItem> meals;

  DayMenu({required this.date, required this.meals});

  factory DayMenu.fromMap(Map<String, dynamic> data) {
    final mealsList = (data['meals'] as List<dynamic>? ?? []);
    return DayMenu(
      date: data['date'] ?? '',
      meals: mealsList
          .map((m) => MealItem.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HostelMess {
  final String hostelId;
  final String hostelName;
  final String hostelType; // Boys/Girls
  final List<DayMenu> menus;

  HostelMess({
    required this.hostelId,
    required this.hostelName,
    required this.hostelType,
    required this.menus,
  });

  factory HostelMess.fromFirestore(Map<String, dynamic> data, String id) {
    final menusList = (data['menus'] as List<dynamic>? ?? []);
    return HostelMess(
      hostelId: id,
      hostelName: data['hostelName'] ?? '',
      hostelType: data['hostelType'] ?? 'Boys',
      menus: menusList
          .map((m) => DayMenu.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }

  DayMenu? getMenuForDate(String date) {
    try {
      return menus.firstWhere((m) => m.date == date);
    } catch (_) {
      return null;
    }
  }
}
