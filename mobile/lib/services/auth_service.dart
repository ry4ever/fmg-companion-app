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

  /// Send a magic link sign-in email to the given address.
  ///
  /// The [email] is where the magic link will be sent.
  /// The [continueUrl] is the URL the user is redirected to after
  /// tapping the link (typically a custom scheme or Firebase Dynamic Link).
  Future<void> sendSignInLink(String email, {String? continueUrl}) async {
    final actionCodeSettings = ActionCodeSettings(
      url: continueUrl ?? 'fmgcompanion://signin',
      handleCodeInApp: true,
      android: const AndroidSettings(
        packageName: 'com.fmg.companion',
        installApp: true,
        minimumVersion: '1',
      ),
      ios: const IOSSettings(
        bundleId: 'com.fmg.companion',
      ),
    );
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  /// Complete email link sign-in with the email and link from the deep link.
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
