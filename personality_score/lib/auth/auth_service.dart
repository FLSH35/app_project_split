import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _errorMessage;

  User? get user => _user;
  String? get errorMessage => _errorMessage;

  AuthService(BuildContext context) {
    _auth.authStateChanges().listen((user) => _onAuthStateChanged(user, context));
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
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

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _onAuthStateChanged(User? user, BuildContext context) {
    _user = user;
    _errorMessage = null;  // Clear error message on successful sign-in
    notifyListeners();

    if (_user != null) {
      // Navigate to profile screen when authenticated
      Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    if (_user != null) {
      await _user!.updateDisplayName(displayName);
      await _user!.reload();
      _user = _auth.currentUser;
      notifyListeners();
    }
  }

  // Method to send a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _errorMessage = null;  // Clear any previous error
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
