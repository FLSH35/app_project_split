import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'signin_desktop_layout.dart'; // Import the desktop layout
import 'package:personality_score/auth/auth_service.dart';
import 'mobile_sidebar.dart'; // Import the mobile sidebar for Sign In
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignedIn = false; // Flag to check sign-in status

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context),
      desktop: SignInDesktopLayout(
        emailController: _emailController,
        passwordController: _passwordController,
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      endDrawer: MobileSidebar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/wasserzeichen.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (!_isSignedIn) ...[
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
                        setState(() {
                          _isSignedIn = true;
                        });
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
                ] else ...[
                  // Show the "Begin Test" button after sign-in
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCB9935),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                    onPressed: () {
                      handleTakeTest(context);
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
      backgroundColor: Color(0xFFEDE8DB),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Sign In'),
      backgroundColor: Colors.grey[300],
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }
}

