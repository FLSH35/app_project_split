import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/models/questionaire_model.dart'; // Adjust the path accordingly
import 'package:personality_score/helper_functions/endpoints.dart';

Future<void> handleTakeTest(BuildContext context) async {
  final model = Provider.of<QuestionnaireModel>(context, listen: false);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = _auth.currentUser;

  if (user == null) {
    Navigator.of(context).pushNamed('/questionnaire');
    return;
  }

  // If the total score is zero, navigate directly to the questionnaire
  if (model.totalScore == 0) {
    await createNextResultsCollection(user.uid);
    Navigator.of(context).pushNamed('/questionnaire');
    return;
  }

  // If the total score is not zero, show the dialog
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFF7F5EF), // Matching background color
        title: SelectableText(
          'Fortfahren oder neu beginnen?',
          style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                'Möchtest du fortfahren, wo du aufgehört hast, oder von vorne beginnen?',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
            ],
          ),
        ),
        actions: [
          // Option to start fresh
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFCB9935), // Gold background for button
              padding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              // Reset the model and create a new results collection
              model.reset();
              createNextResultsCollection(user.uid).then((_) {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/questionnaire'); // Start fresh
              });
            },
            child: Text(
              'Neu beginnen',
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            ),
          ),
          // Option to continue from the last page
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent, // Transparent background
              padding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              // Continue from the last saved progress
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