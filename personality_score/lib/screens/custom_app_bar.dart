import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:personality_score/models/questionaire_model.dart';
import 'package:flutter_svg/flutter_svg.dart';  // Import the flutter_svg package
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF7F5EF),
      // Make the container transparent to match the background
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      // Padding for spacing
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // Ensure the column doesn't take unnecessary space
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCB9935), // Button background color
                  elevation: 0, // No shadow effect
                  shape: RoundedRectangleBorder( // Create square corners
                    borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
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

              SizedBox(width: 20),
              // Add space between the buttons and the right end
            ],
          ),
          SizedBox(height: 8), // Space between the two rows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavButton(context, 'ALLGEMEIN', '/home'),
              SizedBox(width: 10),
              SvgPicture.asset(
                'assets/logo.svg', // Your logo file
                height: 40, // Adjust logo size if needed
              ),
              SizedBox(width: 10),
              _buildNavButton(
                  context, 'STUFEN', '/personality_types'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 60); //

  Widget _buildNavButton(BuildContext context, String label, String route) {
    bool isSelected = ModalRoute
        .of(context)
        ?.settings
        .name == route;
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent, // No background color
        padding: EdgeInsets.symmetric(horizontal: 20),
      ),
      onPressed: () {
        Navigator.of(context).pushReplacementNamed(route);
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Color(0xFFCB9935) : Colors.black,
          // Gold when selected
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Color _getIconColor(BuildContext context, String route) {
    return ModalRoute.of(context)?.settings.name == route
        ? Color(0xFFCB9935) // Gold when on the profile page
        : Colors.black; // Default color for the icon
  }
}



