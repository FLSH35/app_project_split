import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'signin_desktop_layout.dart'; // Import the desktop layout
import 'package:personality_score/auth/auth_service.dart';
import 'mobile_sidebar.dart'; // Import the mobile sidebar for Sign In

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context),  // Mobile layout for screens < 600px
      desktop: SignInDesktopLayout(
        emailController: _emailController,
        passwordController: _passwordController,
      ), // Desktop layout for larger screens
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context), // Add AppBar for mobile to open the sidebar
      endDrawer: MobileSidebar(), // Mobile sidebar for sign-in page
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
      backgroundColor: Color(0xFFEDE8DB),
    );
  }

  // Mobile AppBar with a menu button to open the sidebar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Sign In'),
      backgroundColor: Colors.grey[300], // Light grey for mobile
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu), // Menu icon to open the right-side drawer for mobile
            onPressed: () {
              Scaffold.of(context).openEndDrawer(); // Open the right-side drawer for mobile
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false, // Remove back button for mobile
    );
  }
}
