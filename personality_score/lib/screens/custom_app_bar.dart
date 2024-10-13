import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

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
                    return IconButton(
                      icon: Icon(Icons.person, color: _getIconColor(context, '/profile')),
                      onPressed: () {
                        if (authService.user == null) {
                          Navigator.of(context).pushNamed('/signin');
                        } else {
                          Navigator.of(context).pushNamed('/profile');
                        }
                      },
                    );
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCB9935),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  onPressed: () {
                    handleTakeTest(context); // Your button action
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
                _buildNavButton(context, 'ALLGEMEIN', '/home'),
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
                _buildNavButton(context, 'STUFEN', '/personality_types'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 30);

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
}
