import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart'; // Created by flutterfire configure
import 'controllers/auth_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboards/student_dashboard.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: ApexApp()));
}

class ApexApp extends StatelessWidget {
  const ApexApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APEX – SLIET Campus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen(); // Not logged in
        }

        // User is logged in, fetch their role from Firestore
        final userDataAsync = ref.watch(userDataProvider);

        return userDataAsync.when(
          data: (appUser) {
            if (appUser == null) {
              return const Scaffold(
                body: Center(child: Text('Profile not found.')),
              );
            }

            // If profile is incomplete, force completion
            if (appUser.fathersName == null || appUser.fathersName!.isEmpty) {
              return CompleteProfileScreen(user: appUser);
            }

            // Route based on role
            if (appUser.role == 'admin' ||
                appUser.role == 'teacher' ||
                appUser.role == 'classRep') {
              return const AdminDashboard();
            }

            // Default to Student Dashboard
            return const StudentDashboard();
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            body: Center(child: Text('Error: $e')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Auth Error: $e')),
      ),
    );
  }
}