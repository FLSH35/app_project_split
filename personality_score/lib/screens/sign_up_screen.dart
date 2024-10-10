import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'signup_desktop_layout.dart';  // Import the desktop layout
import 'package:personality_score/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mobile_sidebar.dart'; // Import the mobile sidebar for Sign Up
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isSignedUp = false; // Flag to check sign-up status
  String? userName; // Variable to store the user's name after sign-up

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context),
      desktop: SignUpDesktopLayout(
        emailController: _emailController,
        passwordController: _passwordController,
        nameController: _nameController,
      ),
    );
  }

  // Mobile-specific layout
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SIGN UP'),
        backgroundColor: Colors.grey[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isSignedUp) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Display Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  await authService.signUpWithEmail(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (authService.user != null) {
                    await authService.user!.updateDisplayName(_nameController.text);
                    await authService.user!.reload();

                    // Save user data to Firestore
                    FirebaseFirestore.instance.collection('users').doc(authService.user!.uid).set({
                      'displayName': _nameController.text,
                      'email': _emailController.text,
                    });

                    setState(() {
                      userName = _nameController.text; // Store the user's name
                      _isSignedUp = true; // Mark user as signed up
                    });
                  }
                },
                child: Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/signin');
                },
                child: Text('Already have an account? Sign In'),
              ),
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  if (authService.errorMessage != null) {
                    return SelectableText(
                      authService.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    );
                  }
                  return Container();
                },
              ),
            ] else ...[
              // Show welcome message and buttons after sign-up
              if (userName != null)
                SelectableText(
                  'Hello, $userName!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCB9935),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                onPressed: () {
                  handleTakeTest(context); // Handle starting the test
                },
                child: Text(
                  'Beginne den Test',
                  style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/profile'); // Go to profile
                },
                child: SelectableText(
                  'Go to Profile',
                  style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                ),
              ),
            ],
          ],
        ),
      ),
      backgroundColor: Color(0xFFEDE8DB),
    );
  }
}
