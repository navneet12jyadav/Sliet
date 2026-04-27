import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/data_controller.dart';
import '../../models/timetable_model.dart';

class TodayTab extends ConsumerStatefulWidget {
  const TodayTab({super.key});

  @override
  ConsumerState<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends ConsumerState<TodayTab> {
  // Page 1000 represents "today"; offsets move forward/backward in days.
  static const int _todayPage = 1000;
  final PageController _pageController =
      PageController(initialPage: _todayPage);
  int _currentPage = _todayPage;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _dateForPage(int page) {
    final offset = page - _todayPage;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: offset));
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(timetableConfigProvider);

    return configAsync.when(
      data: (config) => _buildPageView(config),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading timetable: $e')),
    );
  }

  Widget _buildPageView(TimetableConfig? config) {
    return Column(
      children: [
        // Navigation header
        _buildDateHeader(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, page) {
              final date = _dateForPage(page);
              return _DayPage(date: date, config: config);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader() {
    final date = _dateForPage(_currentPage);
    final isToday = _currentPage == _todayPage;

    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        border: Border(bottom: BorderSide(color: Colors.deepPurple.shade100)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.deepPurple.shade700, size: 28),
            onPressed: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          Column(
            children: [
              Text(
                isToday ? 'Today' : DateFormat('EEEE').format(date),
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple.shade400,
                  fontSize: 13,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple.shade800,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (!isToday)
                TextButton(
                  onPressed: () => _pageController.jumpToPage(_todayPage),
                  child: Text(
                    'Today',
                    style: GoogleFonts.poppins(
                      color: Colors.deepPurple.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: Colors.deepPurple.shade700,
                  size: 28,
                ),
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget that renders the timetable for a single calendar date
// ---------------------------------------------------------------------------
class _DayPage extends ConsumerWidget {
  final DateTime date;
  final TimetableConfig? config;

  const _DayPage({required this.date, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check for holiday
    if (config != null && config!.isHoliday(date)) {
      return _buildHolidayView();
    }

    final cyclicDay = config?.getCyclicDayFor(date) ?? 1;
    final dayDataAsync = ref.watch(timetableDayProvider(cyclicDay));

    return dayDataAsync.when(
      data: (dayData) => _buildClassList(context, cyclicDay, dayData),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildHolidayView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Holiday / Leave Day',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No classes scheduled',
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(
    BuildContext context,
    int cyclicDay,
    TimetableDay? dayData,
  ) {
    final classes = dayData?.classes ?? [];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Day $cyclicDay',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${classes.length} class${classes.length == 1 ? '' : 'es'}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (classes.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No classes for Day $cyclicDay',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ClassCard(entry: classes[index]),
              childCount: classes.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card widget for a single class entry
// ---------------------------------------------------------------------------
class _ClassCard extends StatelessWidget {
  final ClassEntry entry;

  const _ClassCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isLab = entry.type.toLowerCase() == 'lab';
    final typeColor = isLab ? Colors.teal : Colors.deepPurple;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            SizedBox(
              width: 60,
              child: Text(
                entry.time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            // Divider line
            Container(
              width: 3,
              height: 60,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // Subject info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.subject,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.instructor,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: typeColor.withOpacity(0.3)),
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
          ],
        ),
      ),
    );
  }
}
