import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademicsTab extends StatefulWidget {
  const AcademicsTab({super.key});

  @override
  State<AcademicsTab> createState() => _AcademicsTabState();
}

class _AcademicsTabState extends State<AcademicsTab> {
  // A list to hold the data for each subject row
  // Format: {"credits": 3, "grade": 10}
  final List<Map<String, int>> _subjects = [
    {"credits": 3, "grade": 10} // Start with one empty row
  ];

  double _calculatedSgpa = 0.0;

  // Standard 10-point scale grades mapped to their point values
  final Map<String, int> _gradePoints = {
    'O (10)': 10,
    'A+ (9)': 9,
    'A (8)': 8,
    'B+ (7)': 7,
    'B (6)': 6,
    'C (5)': 5,
    'P (4)': 4,
    'F (0)': 0,
  };

  void _addSubject() {
    setState(() {
      _subjects.add({"credits": 3, "grade": 10});
    });
  }

  void _calculateSGPA() {
    int totalCredits = 0;
    int totalPoints = 0;

    for (var subject in _subjects) {
      totalCredits += subject["credits"]!;
      totalPoints += (subject["credits"]! * subject["grade"]!);
    }

    setState(() {
      if (totalCredits == 0) {
        _calculatedSgpa = 0.0;
      } else {
        _calculatedSgpa = totalPoints / totalCredits;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SGPA Calculator', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
        automaticallyImplyLeading: false, // Hides the back button since it's a tab
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The dynamic list of subjects
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text('Subject ${index + 1}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 10),
                          // Credits Dropdown
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<int>(
                              initialValue: _subjects[index]["credits"],
                              decoration: const InputDecoration(labelText: 'Credits', border: OutlineInputBorder()),
                              items: [1, 2, 3, 4, 5].map((credit) {
                                return DropdownMenuItem(value: credit, child: Text('$credit Cr'));
                              }).toList(),
                              onChanged: (val) => setState(() => _subjects[index]["credits"] = val!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Grade Dropdown
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              initialValue: _subjects[index]["grade"],
                              decoration: const InputDecoration(labelText: 'Grade', border: OutlineInputBorder()),
                              items: _gradePoints.entries.map((entry) {
                                return DropdownMenuItem(value: entry.value, child: Text(entry.key));
                              }).toList(),
                              onChanged: (val) => setState(() => _subjects[index]["grade"] = val!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Buttons and Results Area
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _addSubject,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subject'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: _calculateSGPA,
                  child: const Text('Calculate'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your SGPA: ',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _calculatedSgpa.toStringAsFixed(2), // Rounds to 2 decimal places
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // Padding for the bottom nav bar
          ],
        ),
      ),
    );
  }
}