import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';

class CompleteProfileScreen extends StatefulWidget {
  final AppUser user;

  const CompleteProfileScreen({super.key, required this.user});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _fathersNameController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _slietEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController(); // Will hold our picked date
  final _yearController = TextEditingController();
  final _roomController = TextEditingController();
  
  // Dropdown Variables
  String? _selectedDegree;
  String? _selectedBranch;
  String? _selectedHostel;

  // Dropdown Options (You can add more later!)
  final List<String> _degrees = ['ICD', 'B.Tech', 'M.Tech', 'Ph.D'];
  final List<String> _branches = ['CS', 'ME', 'FE', 'ECE', 'EE', 'ICE', 'CIVIL'];
  final List<String> _hostels = ['BH-1', 'BH-2', 'BH-3', 'BH-4', 'GH-1', 'GH-2', 'Day Scholar'];

  bool _isLoading = false;

  // --- THE CALENDAR PICKER FUNCTION ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Opens to today
      firstDate: DateTime(1990),   // Furthest they can go back
      lastDate: DateTime.now(),    // Prevents selecting future dates
    );
    if (picked != null) {
      setState(() {
        // Formats date nicely: DD/MM/YYYY
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _saveProfile() async {
    if (_fathersNameController.text.isEmpty || _selectedDegree == null || _selectedBranch == null || _selectedHostel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill out all required fields!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
        'fathersName': _fathersNameController.text.trim(),
        'personalEmail': _personalEmailController.text.trim(),
        'slietEmail': _slietEmailController.text.trim(),
        'phoneNo': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'dob': _dobController.text.trim(),
        'course': _selectedDegree, // Saving the dropdown choice
        'branch': _selectedBranch, // Saving the dropdown choice
        'year': _yearController.text.trim(),
        'hostelNo': _selectedHostel, // Saving the dropdown choice
        'roomNo': _roomController.text.trim(),
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Text Field Helper
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), prefixIcon: Icon(icon)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Your Profile', style: GoogleFonts.poppins()), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome, ${widget.user.name}!', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Reg No: ${widget.user.registrationNo}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const Divider(height: 30),
            
            _buildTextField(_fathersNameController, "Father's Name", Icons.person_outline),
            _buildTextField(_personalEmailController, "Personal Email", Icons.email, type: TextInputType.emailAddress),
            _buildTextField(_slietEmailController, "SLIET Email", Icons.school, type: TextInputType.emailAddress),
            _buildTextField(_phoneController, "Phone Number", Icons.phone, type: TextInputType.phone),
            _buildTextField(_addressController, "Home Address", Icons.home),
            
            // --- THE DATE PICKER TEXT FIELD ---
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _dobController,
                readOnly: true, // Prevents manual typing
                onTap: () => _selectDate(context), // Opens the calendar when tapped
                decoration: const InputDecoration(
                  labelText: "Date of Birth (Select)", 
                  border: OutlineInputBorder(), 
                  prefixIcon: Icon(Icons.calendar_today)
                ),
              ),
            ),
            
            const Divider(height: 30),
            Text('Academic & Hostel Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // --- DEGREE DROPDOWN ---
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Degree", border: OutlineInputBorder(), prefixIcon: Icon(Icons.school)),
              initialValue: _selectedDegree,
              items: _degrees.map((deg) => DropdownMenuItem(value: deg, child: Text(deg))).toList(),
              onChanged: (val) => setState(() => _selectedDegree = val),
            ),
            const SizedBox(height: 16),

            // --- BRANCH DROPDOWN ---
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Specialization", border: OutlineInputBorder(), prefixIcon: Icon(Icons.book)),
              initialValue: _selectedBranch,
              items: _branches.map((branch) => DropdownMenuItem(value: branch, child: Text(branch))).toList(),
              onChanged: (val) => setState(() => _selectedBranch = val),
            ),
            const SizedBox(height: 16),

            _buildTextField(_yearController, "Admission Year (e.g., 2024)", Icons.timeline, type: TextInputType.number),

            Row(
              children: [
                // --- HOSTEL DROPDOWN ---
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Hostel", border: OutlineInputBorder(), prefixIcon: Icon(Icons.apartment)),
                    initialValue: _selectedHostel,
                    items: _hostels.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                    onChanged: (val) => setState(() => _selectedHostel = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildTextField(_roomController, "Room", Icons.door_front_door)),
              ],
            ),
            
            const SizedBox(height: 20),
            _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                    onPressed: _saveProfile, 
                    child: Text('Save Profile', style: GoogleFonts.poppins(fontSize: 18))
                  ),
          ],
        ),
      ),
    );
  }
}