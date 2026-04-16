import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // NEW: The secret code controller
  final _secretCodeController = TextEditingController(); 
  
  String _selectedRole = 'student';
  bool _isLoading = false;

  // Hardcoded passwords for your college staff (You can change these!)
  final String _teacherPasscode = "SLIET-TEACH-2026";
  final String _adminPasscode = "SLIET-ADMIN-SUPER";

  void _signup() async {
    // 🚨 THE SECURITY BOUNCER
    if (_selectedRole == 'teacher' && _secretCodeController.text != _teacherPasscode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Teacher Passcode!")));
      return;
    }
    if (_selectedRole == 'admin' && _secretCodeController.text != _adminPasscode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Admin Passcode!")));
      return;
    }

    setState(() => _isLoading = true);
    
    // Call our existing Auth Service
    String? result = await AuthService().signUp(
      name: _nameController.text,
      registrationNo: _regNoController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );
    
    setState(() => _isLoading = false);

    if (result == "Success") {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create SLIET Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            
            // Note: For staff, this could be their Employee ID instead of Reg No
            TextField(controller: _regNoController, decoration: const InputDecoration(labelText: 'Registration / Employee Number', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password (min 6 chars)', border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(labelText: 'Select Role', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                  _secretCodeController.clear(); // Clear the code if they switch roles
                });
              },
            ),
            const SizedBox(height: 16),

            // 🚨 CONDITIONAL UI: Only show this text box if they are NOT a student
            if (_selectedRole != 'student') ...[
              TextField(
                controller: _secretCodeController,
                decoration: InputDecoration(
                  labelText: 'Enter $_selectedRole Passcode', 
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.red.shade50,
                  prefixIcon: const Icon(Icons.security, color: Colors.red),
                ),
                obscureText: true, // Hides the passcode as they type
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),
            _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _signup, 
                    child: const Text('Secure Sign Up', style: TextStyle(fontSize: 18))
                  ),
          ],
        ),
      ),
    );
  }
}