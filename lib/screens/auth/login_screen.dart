import 'signup_screen.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }

class _LoginScreenState extends State<LoginScreen> {
  final _regNoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    String? result = await AuthService().login(registrationNo: _regNoController.text, password: _passwordController.text);
    setState(() => _isLoading = false);
    if (result != "Success") ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? "Error")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('SLIET Hub Login', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(controller: _regNoController, decoration: const InputDecoration(labelText: 'Registration Number', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 24),
            _isLoading ? const Center(child: CircularProgressIndicator()) 
            : ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
              },
              child: const Text("Don't have an account? Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}        