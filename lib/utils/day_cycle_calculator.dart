// Day cycle system: Day 1-7 rotating cycle
// Reference date: Jan 6, 2025 (Monday) = Day 1
// Weekends and holidays are excluded from the cycle
class DayCycleCalculator {
  static final DateTime _referenceDate = DateTime(2025, 1, 6);

  static int getDayNumber(DateTime date, List<DateTime> holidays) {
    int workingDays = 0;
    DateTime current = _referenceDate;

    while (current.isBefore(date)) {
      if (!_isWeekend(current) && !_isHoliday(current, holidays)) {
        workingDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return (workingDays % 7) + 1;
  }

  static bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static bool _isHoliday(DateTime date, List<DateTime> holidays) {
    return holidays.any(
      (h) => h.year == date.year && h.month == date.month && h.day == date.day,
    );
  }

  static bool isHolidayOrWeekend(DateTime date, List<DateTime> holidays) {
    return _isWeekend(date) || _isHoliday(date, holidays);
  }
}
