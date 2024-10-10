import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'package:personality_score/models/questionaire_model.dart';
import 'custom_app_bar.dart'; // Import your custom app bar
import 'custom_footer.dart'; // Import your QuestionnaireModel
import 'dart:math'; // For 3D transformations

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
            CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, double screenHeight, double screenWidth) {
    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/background_personality_type.svg',
            fit: BoxFit.cover,
            width: screenWidth,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                SelectableText(
                  "Die 8 Stufen der Persönlichkeitsentwicklung – auf welcher stehst du?",
                  style: TextStyle(
                    fontSize: screenHeight * 0.042,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SelectableText(
                  "Erhalte messerscharfe Klarheit über deinen Entwicklungsstand und erfahre, wie du das nächste Level erreichen kannst.",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCB9935),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.07,
                      vertical: screenHeight * 0.021,
                    ),
                  ),
                  onPressed: () {
                    handleTakeTest(context); // Call to the test function
                  },
                  child: Text(
                    'Beginne den Test',
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
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/background_personality_type.svg',
            fit: BoxFit.cover,
            width: screenWidth,
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
                    SelectableText(
                      "PERSOENLICHKEITSSTUFEN",
                      style: TextStyle(
                        fontSize: screenHeight * 0.021,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 20),
                    SelectableText(
                      "Verstehe dich selbst und andere ",
                      style: TextStyle(
                        fontSize: screenHeight * 0.056,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 20),
                    SelectableText(
                      "Vom Anonymus zum Life Artist: Die 8 Stufen symbolisieren die wichtigsten Etappen auf dem Weg, dein Potenzial voll auszuschöpfen. Mit einem fundierten Verständnis des Modells wirst du nicht nur dich selbst, sondern auch andere Menschen viel besser verstehen und einordnen können.",
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                  child: AdventurerImage(screenWidth: screenWidth, screenHeight: screenHeight),
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
            width: screenWidth * 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                SelectableText(
                  "Die 8 Stufen der Persönlichkeitsentwicklung – auf welcher stehst du?",
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.07,
                      vertical: screenHeight * 0.021,
                    ),
                  ),
                  onPressed: () {
                    handleTakeTest(context);
                  },
                  child: Text(
                    'Beginne den Test',
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
}

// Widget for the tilted Adventurer Image with hover effect
class AdventurerImage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  AdventurerImage({required this.screenWidth, required this.screenHeight});

  @override
  _AdventurerImageState createState() => _AdventurerImageState();
}

class _AdventurerImageState extends State<AdventurerImage> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        // No transformation for the container itself
        child: Transform(
          transform: !isHovered ? Matrix4.identity() : Matrix4.identity()
            ..setEntry(3, 2, 0.000) // For 3D perspective
            ..rotateY(pi / 1), // Tilt image to the right
          alignment: FractionalOffset.center, // Pivot at the center
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: !isHovered ? widget.screenWidth * 0.4 : widget.screenWidth * 0.5,
            height: !isHovered ? widget.screenHeight * 0.4 : widget.screenHeight * 0.5,
            child: Image.asset('assets/adventurer_front.png'),
          ),
        ),
      ),
    );
  }
}
