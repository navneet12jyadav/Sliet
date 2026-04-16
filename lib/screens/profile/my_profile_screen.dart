import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // Controllers for editable fields
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _hostelController = TextEditingController();
  final _roomController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch current data from Firestore
  Future<void> _loadUserData() async {
    if (currentUser == null) return;
    
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        _phoneController.text = data['phoneNo'] ?? '';
        _addressController.text = data['address'] ?? '';
        _hostelController.text = data['hostelNo'] ?? '';
        _roomController.text = data['roomNo'] ?? '';
        _isLoading = false;
      });
    }
  }

  // Save changes to Firestore
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'phoneNo': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'hostelNo': _hostelController.text.trim(),
        'roomNo': _roomController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated Successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- STATIC PROFILE ICON ---
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple.shade50,
              child: const Icon(Icons.person, size: 60, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            Text('Update Your Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 40),

            // --- EDITABLE FIELDS ---
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 16),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: "Home Address", border: OutlineInputBorder(), prefixIcon: Icon(Icons.home))),
            const SizedBox(height: 16),
            TextField(controller: _hostelController, decoration: const InputDecoration(labelText: "Hostel (e.g., BH-1)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.apartment))),
            const SizedBox(height: 16),
            TextField(controller: _roomController, decoration: const InputDecoration(labelText: "Room Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.door_front_door))),
            
            const SizedBox(height: 30),
            _isSaving 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                      onPressed: _saveProfile,
                      child: Text('Save Changes', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}