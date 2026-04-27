import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../timetable/today_tab.dart';
import '../timetable/tomorrow_tab.dart';
import '../mess/mess_tab.dart';
import '../profile/profile_tab.dart';
import '../notices/notice_board_screen.dart';
import '../map/campus_map_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  // 4-tab navigation: Today, Tomorrow, Mess, Profile
  static const List<Widget> _tabs = [
    TodayTab(),
    TomorrowTab(),
    MessTab(),
    ProfileTab(),
  ];

  static const List<String> _tabTitles = [
    'Today',
    'Tomorrow',
    'Mess',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tabTitles[_selectedIndex],
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
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
                  Text(
                    'Campus Menu',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Official Notices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NoticeBoardScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Campus Directory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CampusMapScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Tomorrow',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Mess',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}