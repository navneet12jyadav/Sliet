import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_service.dart';
import '../../controllers/data_controller.dart';
import 'trending_tab.dart';
import 'academics_tab.dart';
import 'placement_tab.dart';
import '../notices/notice_board_screen.dart';
import '../map/campus_map_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  // The tabs for our bottom navigation bar
  final List<Widget> _tabs = [
    const HomeTab(),
    const PlacementTab(), // <--- WE CHANGED THIS
    const TrendingTab(),
    const AcademicsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SLIET Hub', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logOut(); // Logs the user out securely
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.school, size: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  Text('SLIET Hub Menu', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Official Notices'),
              onTap: () {
                Navigator.pop(context); // Close the drawer first
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeBoardScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Campus Directory'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to the real Map Screen!
                Navigator.push(context, MaterialPageRoute(builder: (_) => CampusMapScreen()));
              },
            ),
          ],
        ),
      ),
      // NEW CODE ENDS HERE

      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
      
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Placements'), // <--- WE CHANGED THIS
        BottomNavigationBarItem(icon: Icon(Icons.whatshot), label: 'Trending'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Academic'),
      ],
      ),
    );
  }
}

// This is the actual content of the Home tab
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This fetches the logged-in user's profile from our Riverpod controller
    final userDataAsync = ref.watch(userDataProvider);

    return userDataAsync.when(
      data: (user) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Welcome back,\n${user?.name ?? 'Student'}!',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildClassesCard(),
            const SizedBox(height: 16),
            _buildMessMenuCard(ref),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading profile: $e')),
    );
  }

  Widget _buildClassesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('Today\'s Classes', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.computer, color: Colors.white)),
              title: Text('Database Management Systems'),
              subtitle: Text('10:00 AM - Room 402'),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildMessMenuCard(WidgetRef ref) {
    // Watch the database stream
    final messMenuStream = ref.watch(messMenuProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('Today\'s Mess Menu', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            
            // Handle the real-time data
            messMenuStream.when(
              data: (menu) {
                if (menu == null) {
                  return const Text("Today's menu hasn't been uploaded yet.");
                }
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.breakfast_dining, color: Colors.orange),
                      title: const Text('Breakfast'),
                      subtitle: Text(menu.breakfast),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lunch_dining, color: Colors.red),
                      title: const Text('Lunch'),
                      subtitle: Text(menu.lunch),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.dinner_dining, color: Colors.indigo),
                      title: const Text('Dinner'),
                      subtitle: Text(menu.dinner),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading menu: $e'),
            ),
          ],
        ),
      ),
    );
  }
}