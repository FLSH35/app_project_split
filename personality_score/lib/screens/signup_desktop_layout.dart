import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_app_bar.dart';

class SignUpDesktopLayout extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;

  SignUpDesktopLayout({
    required this.emailController,
    required this.passwordController,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sign Up - Desktop',
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
                  // Display Name Input
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Display Name'),
                  ),
                  SizedBox(height: 20),

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

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: () async {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      await authService.signUpWithEmail(
                        emailController.text,
                        passwordController.text,
                      );
                      if (authService.user != null) {
                        // Update the user's display name
                        await authService.user!.updateDisplayName(nameController.text);
                        await authService.user!.reload();

                        // Optionally save the user data in Firestore
                        FirebaseFirestore.instance.collection('users').doc(authService.user!.uid).set({
                          'displayName': nameController.text,
                          'email': emailController.text,
                        });

                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                    child: Text('Sign Up'),
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
