// lib/questionnaire_helpers.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/models/questionaire_model.dart'; // Make sure to adjust the path accordingly

void handleTakeTest(BuildContext context) {
  final model = Provider.of<QuestionnaireModel>(context, listen: false);

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
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
              ),
            ),
            onPressed: () {
              model.resetQuestionnaire();
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
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
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
