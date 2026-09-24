
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  bool _googleInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize();

    _googleInitialized = true;
  }

  Future<User?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        return null;
      }

      await user.updateDisplayName(fullName);

      await user.reload();

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e.code),
      );
    }
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        return null;
      }

      await user.reload();

      final User? refreshedUser =
          _auth.currentUser;

      if (refreshedUser == null) {
        return null;
      }

      if (!refreshedUser.emailVerified) {
        await _auth.signOut();

        throw Exception(
          'Please verify your email before logging in.',
        );
      }

      return refreshedUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e.code),
      );
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      debugPrint(
        'GOOGLE: Initializing Google Sign-In...',
      );

      await _initializeGoogleSignIn();

      debugPrint(
        'GOOGLE: Google Sign-In initialized.',
      );

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      debugPrint(
        'GOOGLE: Google account selected: '
        '${googleUser.email}',
      );

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken =
          googleAuth.idToken;

      debugPrint(
        'GOOGLE: ID token exists: '
        '${idToken != null}',
      );

      if (idToken == null) {
        throw Exception(
          'Google Sign-In did not return an ID token.',
        );
      }

      final AuthCredential credential =
          GoogleAuthProvider.credential(
        idToken: idToken,
      );

      debugPrint(
        'GOOGLE: Firebase credential created.',
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(
        credential,
      );

      final User? user =
          userCredential.user;

      if (user == null) {
        return null;
      }

      await user.reload();

      final User? refreshedUser =
          _auth.currentUser;

      if (refreshedUser == null) {
        return null;
      }

      debugPrint(
        'GOOGLE: Firebase authentication successful.',
      );

      debugPrint(
        'GOOGLE: Firebase UID: '
        '${refreshedUser.uid}',
      );

      debugPrint(
        'GOOGLE: Firebase email: '
        '${refreshedUser.email}',
      );

      return refreshedUser;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'GOOGLE FIREBASE ERROR: '
        'code=${e.code}',
      );

      debugPrint(
        'GOOGLE FIREBASE ERROR: '
        'message=${e.message}',
      );

      throw Exception(
        _getAuthErrorMessage(e.code),
      );
    } on GoogleSignInException catch (e) {
      debugPrint(
        'GOOGLE SIGN-IN ERROR: '
        'code=${e.code}',
      );

      debugPrint(
        'GOOGLE SIGN-IN ERROR: '
        'description=${e.description}',
      );

      debugPrint(
        'GOOGLE SIGN-IN ERROR: '
        'details=$e',
      );

      if (e.code ==
          GoogleSignInExceptionCode.canceled) {
        return null;
      }

      throw Exception(
        'Google Sign-In error: '
        '${e.code} - ${e.description}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'GOOGLE UNKNOWN ERROR: $e',
      );

      debugPrint(
        'GOOGLE UNKNOWN STACK TRACE: $stackTrace',
      );

      throw Exception(
        'Google Sign-In error: $e',
      );
    }
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e.code),
      );
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final User? user =
          _auth.currentUser;

      if (user == null) {
        throw Exception(
          'No authenticated user found.',
        );
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e.code),
      );
    }
  }

  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e.code),
      );
    }
  }

  Future<String?> getIdToken() async {
    try {
      final User? user =
          _auth.currentUser;

      if (user == null) {
        return null;
      }

      return await user.getIdToken();
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e.code),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await _auth.signOut();
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account was found with this email.';

      case 'wrong-password':
        return 'The password is incorrect.';

      case 'invalid-credential':
        return 'The email or password is incorrect.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'user-token-expired':
        return 'Your session has expired. Please log in again.';

      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';

      case 'credential-already-in-use':
        return 'This Google account is already linked to another account.';

      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';

      case 'popup-closed-by-user':
        return 'Google Sign-In was cancelled.';

      default:
        return 'An authentication error occurred.';
    }
  }
}
