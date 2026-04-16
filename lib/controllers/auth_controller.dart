import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final authStateProvider = StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

final userDataProvider = FutureProvider<AppUser?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  return doc.exists ? AppUser.fromFirestore(doc.data()!, user.uid) : null;
});