import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart'; // Created by flutterfire configure
import 'controllers/auth_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboards/student_dashboard.dart';
import 'screens/auth/complete_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: SlietHubApp()));
}

class SlietHubApp extends StatelessWidget {
  const SlietHubApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'SLIET Hub', home: const AuthWrapper());
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
            if (appUser == null) return const Scaffold(body: Center(child: Text('Profile not found.')));
            
            // THE NEW TRAFFIC COP LOGIC:
            // If fathersName is null or empty, force them to complete their profile
            if (appUser.fathersName == null || appUser.fathersName!.isEmpty) {
              return CompleteProfileScreen(user: appUser);
            }
            
            // Otherwise, they are fully onboarded! Route based on role:
            if (appUser.role == 'admin') return const Scaffold(body: Center(child: Text('Admin Dashboard')));
            if (appUser.role == 'teacher') return const Scaffold(body: Center(child: Text('Teacher Dashboard')));
            
            // Default to Student Dashboard
            return const StudentDashboard();
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth Error: $e'))),
    );
  }
}