import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/data_controller.dart';
import '../../models/timetable_model.dart';
import '../../models/holiday_model.dart';
import '../../utils/day_cycle_calculator.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holidaysAsync = ref.watch(holidaysProvider);

    return holidaysAsync.when(
      data: (holidays) {
        final holidayDates = holidays.map((h) => h.date).toList();
        final today = DateTime.now();
        final isOffDay = DayCycleCalculator.isHolidayOrWeekend(today, holidayDates);

        if (isOffDay) {
          final holiday = _getHoliday(today, holidays);
          return _buildOffDayView(context, holiday);
        }

        final dayNumber = DayCycleCalculator.getDayNumber(today, holidayDates);
        return _TimetableDayView(
          dayNumber: dayNumber,
          label: 'Today',
          date: today,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }

  Holiday? _getHoliday(DateTime date, List<Holiday> holidays) {
    try {
      return holidays.firstWhere(
        (h) =>
            h.date.year == date.year &&
            h.date.month == date.month &&
            h.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  Widget _buildOffDayView(BuildContext context, Holiday? holiday) {
    final isWeekend = DateTime.now().weekday == DateTime.saturday ||
        DateTime.now().weekday == DateTime.sunday;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              isWeekend ? 'Weekend!' : 'Holiday!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            if (holiday != null) ...[
              const SizedBox(height: 8),
              Text(
                holiday.name,
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'No classes today. Enjoy your day!',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimetableDayView extends ConsumerWidget {
  final int dayNumber;
  final String label;
  final DateTime date;

  const _TimetableDayView({
    required this.dayNumber,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(timetableForDayProvider(dayNumber));

    return Column(
      children: [
        _buildDayHeader(context),
        Expanded(
          child: classesAsync.when(
            data: (classes) {
              if (classes.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: classes.length,
                itemBuilder: (context, index) =>
                    _ClassCard(timetableClass: classes[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error loading classes: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            'Day $dayNumber',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _formatDate(date),
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_available, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Classes Today',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Day $dayNumber schedule is empty',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _ClassCard extends StatelessWidget {
  final TimetableClass timetableClass;

  const _ClassCard({required this.timetableClass});

  @override
  Widget build(BuildContext context) {
    final isLab = timetableClass.type == 'Lab';
    final typeColor = isLab ? Colors.green : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          timetableClass.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          timetableClass.type,
                          style: GoogleFonts.poppins(
                            color: typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${timetableClass.startTime} – ${timetableClass.endTime}',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.room, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        timetableClass.room,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        timetableClass.instructor,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
