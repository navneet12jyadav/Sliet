import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// The Blueprint for a Campus Spot
class CampusSpot {
  final String name;
  final String description;
  final String category; // e.g., Hostel, Academic, Utility
  final IconData icon;
  final double lat;
  final double lng;

  CampusSpot(this.name, this.description, this.category, this.icon, this.lat, this.lng);
}

class CampusMapScreen extends StatelessWidget {
  CampusMapScreen({super.key});

  // Our hardcoded list of SLIET locations (You can update these exact coordinates later!)
  final List<CampusSpot> spots = [
    CampusSpot('Central Library', 'Main study center with AC reading rooms.', 'Academic', Icons.local_library, 30.2285, 75.6705),
    CampusSpot('Giani Zail Singh Hostel', 'Boys PG Hostel.', 'Hostel', Icons.apartment, 30.2312, 75.6721),
    CampusSpot('Mechanical Block', 'Workshops and Mech Dept classrooms.', 'Academic', Icons.engineering, 30.217893968054074, 75.7003506072777),
    CampusSpot('Student Activity Centre', 'Clubs, societies, and indoor sports.', 'Utility', Icons.sports_basketball, 30.2290, 75.6750),
    CampusSpot('Health Centre', '24/7 basic medical facilities.', 'Utility', Icons.local_hospital, 30.2305, 75.6710),
  ];

  // Function to open Google Maps
  Future<void> _openMaps(double lat, double lng) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open map');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Directory', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: spots.length,
        itemBuilder: (context, index) {
          final spot = spots[index];
          
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(spot.icon, size: 32, color: Colors.deepPurple),
                  ),
                  const SizedBox(width: 16),
                  
                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(spot.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(spot.category, style: const TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(spot.description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  
                  // Navigate Button
                  IconButton(
                    icon: const Icon(Icons.navigation, color: Colors.blue),
                    onPressed: () => _openMaps(spot.lat, spot.lng),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}