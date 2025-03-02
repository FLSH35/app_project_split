import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _errorMessage;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get email => _user?.email; // Added email getter

  bool get isAnonymous => _user?.isAnonymous ?? true;
  bool get isLoggedIn => _user != null && !_user!.isAnonymous;

  AuthService(BuildContext context) {
    _auth.authStateChanges().listen((user) => _onAuthStateChanged(user, context));
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      if (_user != null && _user!.isAnonymous) {
        // Link the anonymous user to a permanent account
        await _user!.linkWithCredential(
          EmailAuthProvider.credential(email: email, password: password),
        );
      } else {
        // Create a new permanent account
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null; // Clear the user
      _errorMessage = null; // Clear error messages
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await signOut();
      Navigator.of(context).pushReplacementNamed('/'); // Navigate to login page
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _onAuthStateChanged(User? user, BuildContext context) {
    _user = user;
    _errorMessage = null; // Clear error message on successful sign-in
    notifyListeners();
  }

  Future<void> updateDisplayName(String displayName) async {
    if (_user != null) {
      await _user!.updateDisplayName(displayName);
      await _user!.reload();
      _user = _auth.currentUser;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _errorMessage = null; // Clear any previous error
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
