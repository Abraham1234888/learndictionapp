import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Re-throw or handle specific error codes as needed by UI
      print('FirebaseAuthException in signIn: ${e.code} ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error in signIn: $e');
      return null;
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException in signUp: ${e.code} ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error in signUp: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}




