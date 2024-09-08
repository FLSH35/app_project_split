// signin_desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'custom_app_bar.dart';

class SignInDesktopLayout extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  SignInDesktopLayout({
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sign In - Desktop',
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0), // Increased padding for desktop
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Email Input
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 20),

                  // Password Input
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),

                  // Sign In Button
                  ElevatedButton(
                    onPressed: () async {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      await authService.signInWithEmail(
                        emailController.text,
                        passwordController.text,
                      );
                      if (authService.user != null) {
                        Navigator.of(context).pushReplacementNamed('/home');
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
