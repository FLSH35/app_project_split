import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          // First row with the buttons (Profile/Login and optionally "Beginne den Test")
          Positioned(
            right: 0,
            top: 0, // Adjusted position to be at the top
            child: Consumer<AuthService>(
              builder: (context, authService, child) {
                if (authService.user == null) {
                  return _buildLoginButton();
                }

                // Use FutureBuilder to fetch `finalCharacter`
                return FutureBuilder<String>(
                  future: _fetchFinalCharacter(authService.user!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCB9935)),
                        strokeWidth: 2.0,
                      );
                    }

                    String character = snapshot.data ?? "Explorer";

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/profile');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/$character.webp',
                              height: 50.0,
                            ),
                            SizedBox(width: 8),
                            Text(
                              authService.user!.displayName ?? "User",
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Konnte die URL nicht öffnen: $url')),
                        );
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

  Widget _buildLoginButton() {
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
          'Anmelden',
          style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        ),
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
          fontSize: 18,
          color: isSelected ? Color(0xFFCB9935) : Colors.black,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Future<String> _fetchFinalCharacter(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['currentFinalCharacter'] ?? 'Explorer';
      }
    } catch (error) {
      print("Error fetching FinalCharacter: $error");
    }
    return 'Explorer'; // Default character
  }
}
