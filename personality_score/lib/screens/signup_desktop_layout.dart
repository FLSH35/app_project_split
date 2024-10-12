import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_app_bar.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';

class SignUpDesktopLayout extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;

  SignUpDesktopLayout({
    required this.emailController,
    required this.passwordController,
    required this.nameController,
  });

  @override
  _SignUpDesktopLayoutState createState() => _SignUpDesktopLayoutState();
}

class _SignUpDesktopLayoutState extends State<SignUpDesktopLayout> {
  bool _isSignedUp = false; // Flag to track if the user has signed up
  String? userName; // Store the signed-up user's name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sign Up - Desktop',
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!_isSignedUp) ...[
                    // Display Name Input
                    TextField(
                      controller: widget.nameController,
                      decoration: InputDecoration(labelText: 'Display Name'),
                    ),
                    SizedBox(height: 20),

                    // Email Input
                    TextField(
                      controller: widget.emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 20),

                    // Password Input
                    TextField(
                      controller: widget.passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),

                    // Sign Up Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        backgroundColor: Color(0xFFCB9935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () async {
                        final authService = Provider.of<AuthService>(context, listen: false);
                        await authService.signUpWithEmail(
                          widget.emailController.text,
                          widget.passwordController.text,
                        );
                        if (authService.user != null) {
                          // Update the user's display name
                          await authService.user!.updateDisplayName(widget.nameController.text);
                          await authService.user!.reload();

                          // Optionally save the user data in Firestore
                          FirebaseFirestore.instance.collection('users').doc(authService.user!.uid).set({
                            'displayName': widget.nameController.text,
                            'email': widget.emailController.text,
                          });

                          setState(() {
                            userName = widget.nameController.text; // Store user's name
                            _isSignedUp = true; // Mark user as signed up
                          });
                        }
                      },
                      child: Text('Registrieren'),
                    ),

                    // Link to Sign In
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/signin');
                      },
                      child: Text('Already have an account? Sign In'),
                    ),

                    // Error Message
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
                      Text(
                        'Hello, $userName!',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    SizedBox(height: 20),

                    // Button to start the test
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        backgroundColor: Color(0xFFCB9935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () {
                        handleTakeTest(context); // Navigate to the test page
                      },
                      child: Text(
                        'Beginne den Test',
                        style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Button to go to profile
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/profile'); // Navigate to profile
                      },
                      child: Text(
                        'Go to Profile',
                        style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFEDE8DB),
    );
  }
}
