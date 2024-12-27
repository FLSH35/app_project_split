// custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:personality_score/screens/signin_dialog.dart'; // Import the SignInDialog

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 30);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isLoading = false; // Loading state

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF7F5EF),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Stack(
        children: [
          // First row with the buttons
          Positioned(
            right: 0,
            top: 0, // Adjusted position to be at the top
            child: Column(
              children: [
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    // Check if user is logged in
                    if (authService.user != null && authService.user!.displayName != null) {
                      // User is logged in -> show profile icon
                      return IconButton(
                        icon: Icon(Icons.person, color: _getIconColor(context, '/profile')),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/profile');
                        },
                      );
                    } else {
                      // User is not logged in -> show login button
                      return Padding(
                        padding: EdgeInsets.all(6.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            side: BorderSide(color: Color(0xFFCB9935)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/profile');
                          },
                          child: Text(
                            'Einloggen',
                            style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 10), // Add some spacing between buttons
                // Test-Button (Beginne den Test) or CircularProgressIndicator
                isLoading
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCB9935)),
                    strokeWidth: 2.0,
                  ),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCB9935),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                    });
                    await handleTakeTest(context);
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Text(
                    'Beginne den Test',
                    style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                  ),
                ),
              ],
            ),
          ),
          // Second row: Logo and navigation buttons
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavButton(context, 'START', '/home'),
                SizedBox(width: 10),
                Flexible(
                  child: GestureDetector(
                    onTap: () async {
                      const url = 'https://ifyouchange.com/';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Image.asset(
                      'assets/Logo-IYC-gross.png',
                      height: 80, // Your desired height
                    ),
                  ),
                ),
                SizedBox(width: 10),
                _buildNavButton(context, 'EINSTUFUNG', '/personality_types'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, String route) {
    bool isSelected = ModalRoute.of(context)?.settings.name == route;
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20),
      ),
      onPressed: () {
        Navigator.of(context).pushReplacementNamed(route);
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Color(0xFFCB9935) : Colors.black,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Color _getIconColor(BuildContext context, String route) {
    return ModalRoute.of(context)?.settings.name == route
        ? Color(0xFFCB9935)
        : Colors.black;
  }

  // Add the showSignInDialog function
  void showSignInDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => SignInDialog(
        emailController: emailController,
        passwordController: passwordController,
        allowAnonymous: false,
      ),
    ).then((_) {
      // Dispose controllers when the dialog is closed
      emailController.dispose();
      passwordController.dispose();
    });
  }
}
