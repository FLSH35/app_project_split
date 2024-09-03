import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:personality_score/models/questionaire_model.dart';
import 'package:flutter_svg/flutter_svg.dart';  // Import the flutter_svg package

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFF7F5EF),
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/logok.svg'
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/home');
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavButton(context, 'PERSONALITY SCORE', '/home'),
          SizedBox(width: 20),
          _buildNavButton(context, 'Personality Types', '/personality_types'),
          SizedBox(width: 20),
          _buildNavButton(context, 'Team Description', '/team_description'), // Add this route to your MaterialApp
        ],
      ),
      actions: [
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
            elevation: 0, // No shadow effect
          ),
          onPressed: () {
            _handleTakeTest(context);
            (context); // Call the new method here
          },
          child: Text(
            'Take the Test ->',
            style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          ),
        ),
      ],
    );
  }

  void _handleTakeTest(BuildContext context) {
    final model = Provider.of<QuestionnaireModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Continue or Start Over?'),
        content: Text('Would you like to continue where you left off or start over?'),
        actions: [
          TextButton(
            onPressed: () {
              model.resetQuestionnaire();
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/questionnaire'); // Start fresh
            },
            child: Text('Start Over'),
          ),
          TextButton(
            onPressed: () {
              model.continueFromLastPage();
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/questionnaire'); // Continue from where left off
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, String route) {
    bool isSelected = ModalRoute.of(context)?.settings.name == route;
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent, // No background color
        padding: EdgeInsets.symmetric(horizontal: 20),
        foregroundColor: isSelected ? Color(0xFFCB9935) : Colors.black, // Text color based on selection
      ),
      onPressed: () {
        Navigator.of(context).pushReplacementNamed(route);
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Color(0xFFCB9935) : Colors.black, // Gold when selected
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

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
