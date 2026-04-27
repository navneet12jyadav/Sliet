import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/data_controller.dart';
import '../../models/mess_menu.dart';

class MessTab extends ConsumerWidget {
  const MessTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDataProvider);

    return userAsync.when(
      data: (user) {
        final hostelId = user?.hostelNo ?? '';
        return _MessContent(hostelId: hostelId);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading profile: $e')),
    );
  }
}

class _MessContent extends ConsumerWidget {
  final String hostelId;

  const _MessContent({required this.hostelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // hostelMessMenuProvider handles empty hostelId by using the global menu.
    final menuAsync = ref.watch(hostelMessMenuProvider(hostelId));

    return menuAsync.when(
      data: (menu) => _buildContent(context, ref, menu),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading menu: $e')),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MessMenu? menu,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.deepPurple, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Mess Menu",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hostelId.isNotEmpty)
                  Text(
                    'Hostel: $hostelId',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (menu == null)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.no_meals,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Today's menu hasn't been uploaded yet.",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          _MealCard(
            mealName: 'Breakfast',
            menu: menu.breakfast,
            icon: Icons.breakfast_dining,
            color: Colors.orange,
            timeHint: '7:30 AM – 9:00 AM',
          ),
          const SizedBox(height: 14),
          _MealCard(
            mealName: 'Lunch',
            menu: menu.lunch,
            icon: Icons.lunch_dining,
            color: const Color(0xFFE6B800),
            timeHint: '12:30 PM – 2:00 PM',
          ),
          const SizedBox(height: 14),
          _MealCard(
            mealName: 'Dinner',
            menu: menu.dinner,
            icon: Icons.dinner_dining,
            color: Colors.indigo,
            timeHint: '7:30 PM – 9:00 PM',
          ),
        ],

        // Tip
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.shade100),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.deepPurple, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Menu is updated daily by your hostel mess administrator.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card for a single meal (Breakfast / Lunch / Dinner)
// ---------------------------------------------------------------------------
class _MealCard extends StatelessWidget {
  final String mealName;
  final String menu;
  final IconData icon;
  final Color color;
  final String timeHint;

  const _MealCard({
    required this.mealName,
    required this.menu,
    required this.icon,
    required this.color,
    required this.timeHint,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon bubble
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mealName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeHint,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    menu,
                    style: const TextStyle(fontSize: 14, height: 1.5),
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
