import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/data_controller.dart';
import '../../models/timetable_model.dart';

class TomorrowTab extends ConsumerWidget {
  const TomorrowTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(timetableConfigProvider);

    return configAsync.when(
      data: (config) => _buildContent(context, ref, config),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    TimetableConfig? config,
  ) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    // Check if tomorrow is a holiday
    if (config != null && config.isHoliday(tomorrowDate)) {
      return _buildHolidayCard(tomorrowDate);
    }

    final cyclicDay = config?.getCyclicDayFor(tomorrowDate) ?? 1;
    final dayDataAsync = ref.watch(timetableDayProvider(cyclicDay));

    return dayDataAsync.when(
      data: (dayData) =>
          _buildPreview(context, tomorrowDate, cyclicDay, dayData),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildHolidayCard(DateTime date) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerRow(date, null),
          const SizedBox(height: 20),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.celebration,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Holiday / Leave Day',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rest up — no classes tomorrow!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(
    BuildContext context,
    DateTime date,
    int cyclicDay,
    TimetableDay? dayData,
  ) {
    final classes = dayData?.classes ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _headerRow(date, cyclicDay),
        const SizedBox(height: 16),

        // Summary chip card
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.deepPurple,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                const Icon(Icons.school, color: Colors.white, size: 36),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${classes.length} Class${classes.length == 1 ? '' : 'es'} Tomorrow',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Day $cyclicDay schedule',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (classes.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No classes scheduled for Day $cyclicDay',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else ...[
          Text(
            'Tomorrow\'s Schedule',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          ...classes.map((entry) => _TomorrowClassTile(entry: entry)),
        ],
      ],
    );
  }

  Widget _headerRow(DateTime date, int? cyclicDay) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tomorrow',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('EEEE, MMM dd').format(date),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        if (cyclicDay != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: Text(
              'Day $cyclicDay',
              style: GoogleFonts.poppins(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Compact tile for tomorrow's preview
// ---------------------------------------------------------------------------
class _TomorrowClassTile extends StatelessWidget {
  final ClassEntry entry;

  const _TomorrowClassTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isLab = entry.type.toLowerCase() == 'lab';
    final typeColor = isLab ? Colors.teal : Colors.deepPurple;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.12),
          child: Icon(
            isLab ? Icons.science : Icons.menu_book,
            color: typeColor,
            size: 20,
          ),
        ),
        title: Text(
          entry.subject,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${entry.time}  •  ${entry.location}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            entry.type,
            style: TextStyle(
              fontSize: 11,
              color: typeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
