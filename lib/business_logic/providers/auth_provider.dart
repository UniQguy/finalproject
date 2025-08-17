import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  static const _kAuthKey = 'auth_is_authenticated';
  static const _kEmailKey = 'auth_user_email';
  static const _kAvatarPathKey = 'auth_user_avatar';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // ✅ works with 6.1.0

  bool _isAuthenticated = false;
  String? _userEmail;
  String? _avatarPath;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get avatarPath => _avatarPath;

  AuthProvider() {
    _loadFromPrefs();
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _isAuthenticated = true;
        _userEmail = user.email;
        _avatarPath = user.photoURL;
        _saveToPrefs();
      } else {
        _isAuthenticated = false;
        _userEmail = null;
        _avatarPath = null;
        _saveToPrefs();
      }
      notifyListeners();
    });
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool(_kAuthKey) ?? false;
    _userEmail = prefs.getString(_kEmailKey);
    _avatarPath = prefs.getString(_kAvatarPathKey);
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAuthKey, _isAuthenticated);
    if (_userEmail != null) {
      await prefs.setString(_kEmailKey, _userEmail!);
    } else {
      await prefs.remove(_kEmailKey);
    }
    if (_avatarPath != null) {
      await prefs.setString(_kAvatarPathKey, _avatarPath!);
    } else {
      await prefs.remove(_kAvatarPathKey);
    }
  }

  /// Simulated email login (replace with Firebase email/password if desired)
  Future<void> login(String email, String password) async {
    _isAuthenticated = true;
    _userEmail = email;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Google Sign-In + FirebaseAuth
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign in aborted by user');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // ✅ works in 6.1.0
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        _isAuthenticated = true;
        _userEmail = user.email;
        _avatarPath = user.photoURL;
        await _saveToPrefs();
        notifyListeners();
      } else {
        throw Exception('Google sign-in failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In error: $e');
      }
      rethrow;
    }
  }

  /// Log out from Firebase & Google
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {
      // ignore
    }
    _isAuthenticated = false;
    _userEmail = null;
    _avatarPath = null;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Update avatar path manually (optional)
  Future<void> updateAvatarPath(String path) async {
    _avatarPath = path;
    await _saveToPrefs();
    notifyListeners();
  }
}
