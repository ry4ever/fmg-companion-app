import 'package:firebase_auth/firebase_auth.dart';

/// Authentication service handling Firebase Auth email link sign-in.
///
/// The backend sends magic links via Encharge API. The mobile app
/// uses Firebase Auth's email link sign-in to complete authentication
/// when the user taps the magic link.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailLink(String email, String emailLink) async {
    return _auth.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool get isSignedIn => _auth.currentUser != null;
}
