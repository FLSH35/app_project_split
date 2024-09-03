import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for handling SVG images
import 'package:provider/provider.dart';
import 'package:personality_score/models/questionaire_model.dart'; // Import your QuestionnaireModel
import 'custom_app_bar.dart'; // Import the custom AppBar

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.33);

  final List<Map<String, String>> personalityTypes = [
    {"value": "Individual", "name": "Individual"},
    {"value": "Traveller", "name": "Traveller"},
    {"value": "Reacher", "name": "Reacher"},
    {"value": "Explorer", "name": "Explorer"},
    {"value": "Resident", "name": "Resident"},
    {"value": "Anonymous", "name": "Anonymous"},
    {"value": "LifeArtist", "name": "Life Artist"},
    {"value": "Adventurer", "name": "Adventurer"},
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: CustomAppBar(
        title: 'Personality Score',
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 350),
                Stack(
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
                                fontSize: screenHeight * 0.042, // 30% smaller
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
                                  horizontal: screenWidth * 0.07, // 30% smaller
                                  vertical: screenHeight * 0.021, // 30% smaller
                                ),
                              ),
                              onPressed: () {
                                _handleTakeTest(context);
                              },
                              child: Text(
                                'Take the Test',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontSize: screenHeight * 0.021, // 30% smaller
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 350),
                Stack(
                  children: [
                    // SVG background for the personality types section
                    Positioned.fill(
                      child: SvgPicture.asset(
                        'assets/background_personality_type.svg',
                        fit: BoxFit.cover,
                        width: screenWidth, // customize size here with width relative to screen width
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20, top: 50, bottom: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "PERSONALITY TYPES",
                                          style: TextStyle(
                                            fontSize: screenHeight * 0.021, // 30% smaller
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                        Text(
                                          "Understand others",
                                          style: TextStyle(
                                            fontSize: screenHeight * 0.056, // 30% smaller
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                        SizedBox(height: 20), // Add space between texts
                                        Text(
                                          "In our free type descriptions you’ll learn what really drives, inspires, and worries different personality types, helping you build more meaningful relationships.",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                            fontSize: screenHeight * 0.021, // 30% smaller
                                          ),
                                          textAlign: TextAlign.center, // Center align the text
                                        ),
                                        SizedBox(height: 70), // Add space before the button
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFCB9935),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.07, // 30% smaller
                                              vertical: screenHeight * 0.021, // 30% smaller
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
                                              fontSize: screenHeight * 0.021, // 30% smaller
                                            ),
                                          ),
                                        ),
                                      ],
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
                                    width: screenWidth * 0.35, // 30% smaller
                                    height: screenHeight * 0.35, // 30% smaller
                                    child: Image.asset('assets/adventurer_front.png'), // Updated image path
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 350),
                Stack(
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
                                fontSize: screenHeight * 0.042, // 30% smaller
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
                                  horizontal: screenWidth * 0.07, // 30% smaller
                                  vertical: screenHeight * 0.021, // 30% smaller
                                ),
                              ),
                              onPressed: () {
                                _handleTakeTest(context);
                              },
                              child: Text(
                                'Take the Test',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontSize: screenHeight * 0.021, // 30% smaller
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 350),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildStatistic(String value, String description) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: screenHeight * 0.042, // 30% smaller
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Roboto',
          ),
        ),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Roboto',
            fontSize: screenHeight * 0.021, // 30% smaller
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(BuildContext context, String imagePath, String name, String type, String testimonial) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      color: Color(0xFFFFF9F2), // Updated testimonial card background color
      margin: EdgeInsets.all(20.0),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(imagePath, width: screenHeight * 0.105, height: screenHeight * 0.105), // 30% smaller
                SizedBox(width: 21),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: screenHeight * 0.021, // 30% smaller
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: screenHeight * 0.0175, // 30% smaller
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              testimonial,
              style: TextStyle(
                fontSize: screenHeight * 0.0175, // 30% smaller
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
