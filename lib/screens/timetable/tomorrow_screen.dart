import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/data_controller.dart';
import '../../models/timetable_model.dart';
import '../../models/holiday_model.dart';
import '../../utils/day_cycle_calculator.dart';

class TomorrowScreen extends ConsumerWidget {
  const TomorrowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holidaysAsync = ref.watch(holidaysProvider);

    return holidaysAsync.when(
      data: (holidays) {
        final holidayDates = holidays.map((h) => h.date).toList();
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final isOffDay =
            DayCycleCalculator.isHolidayOrWeekend(tomorrow, holidayDates);

        if (isOffDay) {
          final holiday = _getHoliday(tomorrow, holidays);
          return _buildOffDayView(tomorrow, holiday);
        }

        final dayNumber = DayCycleCalculator.getDayNumber(tomorrow, holidayDates);
        return _TomorrowDayView(dayNumber: dayNumber, date: tomorrow);
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

  Widget _buildOffDayView(DateTime tomorrow, Holiday? holiday) {
    final isWeekend = tomorrow.weekday == DateTime.saturday ||
        tomorrow.weekday == DateTime.sunday;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.weekend, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              isWeekend ? 'Weekend Tomorrow!' : 'Holiday Tomorrow!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            if (holiday != null) ...[
              const SizedBox(height: 8),
              Text(
                holiday.name,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'No classes tomorrow.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _TomorrowDayView extends ConsumerWidget {
  final int dayNumber;
  final DateTime date;

  const _TomorrowDayView({required this.dayNumber, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(timetableForDayProvider(dayNumber));

    return classesAsync.when(
      data: (classes) => Column(
        children: [
          _buildSummaryHeader(classes),
          Expanded(
            child: classes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: classes.length,
                    itemBuilder: (context, index) =>
                        _TomorrowClassCard(timetableClass: classes[index]),
                  ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error loading classes: $e')),
    );
  }

  Widget _buildSummaryHeader(List<TimetableClass> classes) {
    final firstClass = classes.isNotEmpty ? classes.first : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tomorrow',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
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
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryChip(
                icon: Icons.class_,
                label: '${classes.length} Classes',
              ),
              if (firstClass != null) ...[
                const SizedBox(width: 12),
                _SummaryChip(
                  icon: Icons.alarm,
                  label: 'First at ${firstClass.startTime}',
                ),
              ],
            ],
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
            'No Classes Tomorrow',
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

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TomorrowClassCard extends StatelessWidget {
  final TimetableClass timetableClass;

  const _TomorrowClassCard({required this.timetableClass});

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
