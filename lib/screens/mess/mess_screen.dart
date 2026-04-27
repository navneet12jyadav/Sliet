import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/data_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/hostel_mess_model.dart';
import '../../utils/hostel_utils.dart';

class MessScreen extends ConsumerStatefulWidget {
  const MessScreen({super.key});

  @override
  ConsumerState<MessScreen> createState() => _MessScreenState();
}

class _MessScreenState extends ConsumerState<MessScreen> {
  DateTime _selectedDate = DateTime.now();

  String get _dateKey {
    final d = _selectedDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDataProvider);

    return userAsync.when(
      data: (user) {
        final hostelId = user?.hostelNo?.isNotEmpty == true
            ? user!.hostelNo!
            : (user != null
                ? HostelUtils.assignHostel(user.registrationNo)
                : 'BH-1');

        final messAsync = ref.watch(hostelMessProvider(hostelId));

        return messAsync.when(
          data: (hostelMess) =>
              _buildContent(hostelMess, hostelId, user?.name ?? 'Student'),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(
      HostelMess? hostelMess, String hostelId, String studentName) {
    final dayMenu = hostelMess?.getMenuForDate(_dateKey);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(hostelMess, hostelId)),
        SliverToBoxAdapter(child: _buildDateNavigation()),
        SliverToBoxAdapter(
          child: dayMenu != null
              ? _buildMealCards(dayMenu)
              : _buildNoMenuPlaceholder(),
        ),
      ],
    );
  }

  Widget _buildHeader(HostelMess? hostelMess, String hostelId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
          Row(
            children: [
              const Icon(Icons.restaurant, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                hostelMess?.hostelName.isNotEmpty == true
                    ? hostelMess!.hostelName
                    : hostelId,
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Mess Menu',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              _selectedDate =
                  _selectedDate.subtract(const Duration(days: 1));
            }),
          ),
          Text(
            _formatDate(_selectedDate),
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCards(DayMenu dayMenu) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: dayMenu.meals.map((meal) => _MealCard(meal: meal)).toList(),
      ),
    );
  }

  Widget _buildNoMenuPlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.no_meals, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Menu Not Available',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Menu for $_dateKey hasn't been uploaded yet.",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

class _MealCard extends StatelessWidget {
  final MealItem meal;

  const _MealCard({required this.meal});

  Color get _headerColor {
    switch (meal.type.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.amber[700] ?? Colors.amber;
      case 'dinner':
        return Colors.deepPurple;
      default:
        return Colors.teal;
    }
  }

  IconData get _mealIcon {
    switch (meal.type.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(_mealIcon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  meal.type,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (meal.startTime.isNotEmpty)
                  Text(
                    '${meal.startTime} – ${meal.endTime}',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: meal.items.isEmpty
                ? Text(
                    'Menu not specified',
                    style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 13),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meal.items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(
                                      top: 7, right: 10),
                                  decoration: BoxDecoration(
                                    color: _headerColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
