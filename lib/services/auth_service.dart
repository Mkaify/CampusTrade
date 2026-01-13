import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET CURRENT USER (This fixes the error)
  User? get currentUser => _auth.currentUser;

  // Sign Up with University Domain Lock
  Future<String?> signUp(String email, String password) async {
    try {
      // DOMAIN CHECK (Enforcing project requirement)
      if (!email.trim().endsWith('@students.uettaxila.edu.pk')) {
        return "Registration Restricted: Only @students.uettaxila.edu.pk emails are allowed.";
      }

      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message; 
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // Login
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}