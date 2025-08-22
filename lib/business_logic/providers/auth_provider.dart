import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Provides authentication state management using Firebase Auth and Google Sign-In,
/// along with persistent state saved in SharedPreferences.
class AuthProvider extends ChangeNotifier {
  static const _kAuthKey = 'auth_is_authenticated';
  static const _kEmailKey = 'auth_user_email';
  static const _kAvatarPath = 'auth_user_avatar';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isAuthenticated = false;
  String? _userEmail;
  String? _avatarPath;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get avatarPath => _avatarPath;

  AuthProvider() {
    _loadFromPrefs();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _isAuthenticated = true;
        _userEmail = user.email;
        _avatarPath = user.photoURL;
      } else {
        _isAuthenticated = false;
        _userEmail = null;
        _avatarPath = null;
      }
      _saveToPrefs();
      notifyListeners();
    });
  }

  /// Loads authentication info from local storage.
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool(_kAuthKey) ?? false;
    _userEmail = prefs.getString(_kEmailKey);
    _avatarPath = prefs.getString(_kAvatarPath);
    notifyListeners();
  }

  /// Saves authentication info to local storage.
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAuthKey, _isAuthenticated);
    if (_userEmail != null) {
      await prefs.setString(_kEmailKey, _userEmail!);
    } else {
      await prefs.remove(_kEmailKey);
    }
    if (_avatarPath != null) {
      await prefs.setString(_kAvatarPath, _avatarPath!);
    } else {
      await prefs.remove(_kAvatarPath);
    }
  }

  /// Creates a new user account with email and password.
  Future<void> signup(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign up');
    }
  }

  /// Signs in an existing user with email and password.
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to login');
    }
  }

  /// Performs Google Sign-In authentication.
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Sign in aborted by user');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) throw Exception('Google Sign-in failed');
    } catch (e) {
      if (kDebugMode) print('Google sign-in error: $e');
      rethrow;
    }
  }

  /// Signs out the current user and clears authentication state.
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {
      // ignore errors on sign out
    }
    _isAuthenticated = false;
    _userEmail = null;
    _avatarPath = null;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Updates user avatar path and persists it.
  Future<void> updateAvatarPath(String path) async {
    _avatarPath = path;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Sends password reset email to the given address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) print('Password reset email error: $e');
      rethrow;
    }
  }
}
