import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore access
import 'custom_app_bar.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';

class SignInDesktopLayout extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  SignInDesktopLayout({
    required this.emailController,
    required this.passwordController,
  });

  @override
  _SignInDesktopLayoutState createState() => _SignInDesktopLayoutState();
}

class _SignInDesktopLayoutState extends State<SignInDesktopLayout> {
  bool _isSignedIn = false; // Flag to check sign-in status
  String? userName; // Variable to store the user's name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sign In - Desktop',
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
                  if (!_isSignedIn) ...[
                    // Email Input
                    TextField(
                      controller: widget.emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      style: TextStyle(color: Colors.black), // Set email text color to white
                    ),
                    SizedBox(height: 20),

                    // Password Input
                    TextField(
                      controller: widget.passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.black), // Set password text color to white
                    ),
                    SizedBox(height: 20),

                    // Forgot Password Button
                    TextButton(
                      onPressed: () async {
                        if (widget.emailController.text.isNotEmpty) {
                          final authService = Provider.of<AuthService>(context, listen: false);
                          await authService.sendPasswordResetEmail(widget.emailController.text);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: SelectableText("Password reset link sent to ${widget.emailController.text}"),
                            backgroundColor: Colors.green,
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: SelectableText("Please enter your email address to reset password."),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Link to Sign Up
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/signup');
                      },
                      child: Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Sign In Button
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
                        await authService.signInWithEmail(
                          widget.emailController.text,
                          widget.passwordController.text,
                        );
                        if (authService.user != null) {
                          await fetchUserName(); // Fetch user name after sign-in
                          setState(() {
                            _isSignedIn = true; // User successfully signed in
                          });
                        }
                      },
                      child: Text('Sign In'),
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
                    // Show welcome message after sign-in
                    if (userName != null)
                      Text(
                        'Hallo $userName!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    SizedBox(height: 20),

                    // Show the "Begin Test" button after sign-in
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
                        handleTakeTest(context); // Navigate to the test
                      },
                      child: Text(
                        'Beginne den Test',
                        style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Show the "Go to Profile" button after sign-in
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

  Future<void> fetchUserName() async {
    final user = Provider.of<AuthService>(context, listen: false).user;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(); // Fetch the user document

      if (snapshot.exists) {
        // Cast snapshot.data() to a Map<String, dynamic>
        final userData = snapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            userName = userData['name']; // Access the user's name safely
          });
        }
      }
    }
  }
}
