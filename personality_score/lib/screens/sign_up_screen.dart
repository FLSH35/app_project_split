import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'signup_desktop_layout.dart';  // Import the desktop layout
import 'package:personality_score/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_app_bar.dart';  // Import the custom app bar
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

                    FirebaseFirestore.instance.collection('users').doc(authService.user!.uid).set({
                      'displayName': _nameController.text,
                      'email': _emailController.text,
                    });

                    setState(() {
                      _isSignedUp = true; // User successfully signed up
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
                    return Text(
                      authService.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    );
                  }
                  return Container();
                },
              ),
            ] else ...[
              // Show the "Begin Test" button after sign-up
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCB9935),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                onPressed: () {
                  handleTakeTest(context); // Your logic to handle test start
                },
                child: Text(
                  'Beginne den Test',
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
