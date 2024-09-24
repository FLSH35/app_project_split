import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
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
                          setState(() {
                            _isSignedIn = true; // User successfully signed in
                          });
                        }
                      },
                      child: Text('Sign In'),
                    ),

                    // Link to Sign Up
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/signup');
                      },
                      child: Text('Don\'t have an account? Sign Up'),
                    ),

                    // Error Message
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
          ],
        ),
      ),
      backgroundColor: Color(0xFFEDE8DB),
    );
  }

}
