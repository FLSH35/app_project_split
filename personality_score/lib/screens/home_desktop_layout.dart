import 'package:flutter/material.dart';
import 'custom_app_bar.dart'; // Import your custom app bar
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:personality_score/models/questionaire_model.dart'; // Import your QuestionnaireModel
class DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB), // Updated background color for the entire scaffold
      appBar: CustomAppBar(title: 'Personality Score'), // Use the custom app bar
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 350),
            _buildHeaderSection(context, screenHeight, screenWidth),
            SizedBox(height: 350),
            _buildPersonalityTypesSection(context, screenHeight, screenWidth),
            SizedBox(height: 350),
            _buildCuriousSection(context, screenHeight, screenWidth), // New Section Added
            SizedBox(height: 350),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, double screenHeight, double screenWidth) {
    return Stack(
      children: [
        // SVG background for the personality types section
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/background_personality_type.svg',
            fit: BoxFit.cover,
            width: screenWidth, // Size adjusted to screen width
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Text(
                  "Curious how accurate we are about you?",
                  style: TextStyle(
                    fontSize: screenHeight * 0.042,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCB9935),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.07,
                      vertical: screenHeight * 0.021,
                    ),
                  ),
                  onPressed: () {
                    _handleTakeTest(context); // Call to the test function
                  },
                  child: Text(
                    'Take the Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.021,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityTypesSection(BuildContext context, double screenHeight, double screenWidth) {
    return Stack(
      children: [
        // SVG background for the personality types section
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/background_personality_type.svg',
            fit: BoxFit.cover,
            width: screenWidth, // Size adjusted to screen width
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 50, bottom: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "PERSONALITY TYPES",
                      style: TextStyle(
                        fontSize: screenHeight * 0.021,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Understand others",
                      style: TextStyle(
                        fontSize: screenHeight * 0.056,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "In our free type descriptions you’ll learn what really drives, inspires, and worries different personality types, helping you build more meaningful relationships.",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        fontSize: screenHeight * 0.021,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 70),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCB9935),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                          vertical: screenHeight * 0.021,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/personality_types');
                      },
                      child: Text(
                        'Learn More',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: screenHeight * 0.021,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: screenWidth * 0.35,
                    height: screenHeight * 0.35,
                    child: Image.asset('assets/adventurer_front.png'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // New function added to build the "Curious" section
  Widget _buildCuriousSection(BuildContext context, double screenHeight, double screenWidth) {
    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/left_background_personality_type.svg',
            fit: BoxFit.fitWidth,
            width: screenWidth * 0.5, // customize size here with width relative to screen width
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Text(
                  "Curious how accurate we are about you?",
                  style: TextStyle(
                    fontSize: screenHeight * 0.042,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCB9935),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.07,
                      vertical: screenHeight * 0.021,
                    ),
                  ),
                  onPressed: () {
                    _handleTakeTest(context); // Call to the test function
                  },
                  child: Text(
                    'Take the Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: screenHeight * 0.021,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  void _handleTakeTest(BuildContext context) {
    final model = Provider.of<QuestionnaireModel>(context, listen: false);

    if (model.answers.any((answer) => answer != null)) {
      // Show choice dialog if there's progress
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
    } else {
      // If no progress, start the questionnaire directly
      Navigator.of(context).pushNamed('/questionnaire');
    }
  }

}