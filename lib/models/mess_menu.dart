class MessMenu {
  final String breakfast;
  final String lunch;
  final String dinner;

  MessMenu({required this.breakfast, required this.lunch, required this.dinner});

  factory MessMenu.fromFirestore(Map<String, dynamic> data) {
    return MessMenu(
      breakfast: data['breakfast'] ?? 'Not updated yet',
      lunch: data['lunch'] ?? 'Not updated yet',
      dinner: data['dinner'] ?? 'Not updated yet',
    );
  }
}