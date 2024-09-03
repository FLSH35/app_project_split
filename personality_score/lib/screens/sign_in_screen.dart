import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'custom_app_bar.dart';  // Import the custom app bar

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sign In',
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
                    await authService.signInWithEmail(
                      _emailController.text,
                      _passwordController.text,
                    );
                    if (authService.user != null) {
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                  child: Text('Sign In'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/signup');
                  },
                  child: Text('Don\'t have an account? Sign Up'),
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
