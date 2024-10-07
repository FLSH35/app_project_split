import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/models/questionaire_model.dart'; // Adjust the path accordingly
import 'package:personality_score/auth/auth_service.dart'; // Import AuthService to check authentication

void handleTakeTest(BuildContext context) {
  final authService = Provider.of<AuthService>(context, listen: false);
  final model = Provider.of<QuestionnaireModel>(context, listen: false);

  // Check if the user is logged in
  if (authService.user == null) {
    // Redirect to sign-in page
    Navigator.of(context).pushNamed('/signin');
    return;
  }


  // If the total score is zero, navigate directly to the questionnaire
  if (model.combinedTotalScore == 0) {
    Navigator.of(context).pushNamed('/questionnaire');
    return;
  }
  // If the total score is not zero, show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFF7F5EF), // Matching background color
        title: Text(
          'Fortfahren oder neu beginnen?',
          style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Möchtest du fortfahren, wo du aufgehört hast, oder von vorne beginnen?',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFCB9935), // Gold background for button
              padding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              model.reset();
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/questionnaire'); // Start fresh
            },
            child: Text(
              'Neu beginnen',
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent, // Transparent background
              padding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              model.continueFromLastPage();
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/questionnaire'); // Continue from where left off
            },
            child: Text(
              'Fortfahren',
              style: TextStyle(color: Color(0xFFCB9935), fontFamily: 'Roboto'),
            ),
          ),
        ],
      );
    },
  );
}
