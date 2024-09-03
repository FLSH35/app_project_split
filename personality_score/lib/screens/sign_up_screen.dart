import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'custom_app_bar.dart';  // Import the custom app bar
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // New Controller for Display Name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sign Up',
      ),  // Replacing the standard AppBar with CustomAppBar
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 1, // Keep the opacity as 1 for full visibility
              child: Image.asset(
                'assets/wasserzeichen.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController, // Display Name Field
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
                      // Update the user's display name
                      await authService.user!.updateDisplayName(_nameController.text);
                      await authService.user!.reload(); // Refresh the user data

                      // Optionally, save the display name in Firestore as well
                      FirebaseFirestore.instance.collection('users').doc(authService.user!.uid).set({
                        'displayName': _nameController.text,
                        'email': _emailController.text,
                        // Add other fields as needed
                      });

                      Navigator.of(context).pushReplacementNamed('/home');
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
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFEDE8DB), // Same background color as PersonalityTypesPage
    );
  }
}
