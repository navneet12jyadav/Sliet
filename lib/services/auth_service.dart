import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hidden domain to satisfy Firebase Auth
  final String _domain = "@sliet.app"; 

  Future<String?> signUp({required String registrationNo, required String password, required String name, required String role}) async {
    try {
      final regNo = registrationNo.trim();
      
      DocumentSnapshot validRegDoc = await _firestore.collection('valid_registrations').doc(regNo).get();
      if (!validRegDoc.exists) return "Access Denied: Registration Number not found.";
      if (validRegDoc.get('isClaimed') ?? false) return "Access Denied: Account already created.";

      // Create account using regNo + hidden domain
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: "$regNo$_domain", 
        password: password.trim()
      );
      
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid, 'name': name.trim(), 'role': role, 'registrationNo': regNo, 'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('valid_registrations').doc(regNo).update({'isClaimed': true});
      return "Success";
    } on FirebaseAuthException catch (e) { return e.message; } catch (e) { return e.toString(); }
  }

  Future<String?> login({required String registrationNo, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: "${registrationNo.trim()}$_domain", 
        password: password.trim()
      );
      return "Success";
    } on FirebaseAuthException catch (e) { return e.message; } catch (e) { return e.toString(); }
  }

  Future<void> logOut() async => await _auth.signOut();
}