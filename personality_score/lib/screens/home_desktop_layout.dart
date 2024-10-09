import 'package:flutter/material.dart';
import 'custom_app_bar.dart'; // Import your custom app bar
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'package:personality_score/models/questionaire_model.dart';

import 'custom_footer.dart'; // Import your QuestionnaireModel

class DesktopLayout extends StatefulWidget {
  @override
  _DesktopLayoutState createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> with SingleTickerProviderStateMixin {
  bool _isHoveredHeader = false;
  bool _isHoveredPersonality = false;
  ScrollController _scrollController = ScrollController();
  AnimationController? _animationController;
  Animation<Offset>? _leftColumnAnimation;
  Animation<Offset>? _rightColumnAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _leftColumnAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0), // Left column flies in from the left
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _rightColumnAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // Right column flies in from the right
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(() {
      if (_scrollController.offset > 300) {
        _animationController!.forward(); // Fly in when scrolling down
      } else if (_scrollController.offset < 300) {
        _animationController!.reverse(); // Fly out when scrolling up
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB), // Updated background color for the entire scaffold
      appBar: CustomAppBar(title: 'Personality Score'), // Use the custom app bar
      body: SingleChildScrollView(
        controller: _scrollController,
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
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _isHoveredHeader = true;
              });
            },
            onExit: (_) {
              setState(() {
                _isHoveredHeader = false;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(_isHoveredHeader ? 1.05 : 1.0), // Smoothly enlarges on hover
              child: Column(
                children: [
                  Text(
                    "Die 8 Stufen der Persönlichkeitsentwicklung – auf welcher stehst du?",
                    style: TextStyle(
                      fontSize: screenHeight * 0.042,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
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
                      handleTakeTest(context);
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
              // Left column animation
              Expanded(
                flex: 1,
                child: SlideTransition(
                  position: _leftColumnAnimation!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            _isHoveredPersonality = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _isHoveredPersonality = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          transform: Matrix4.identity()..scale(_isHoveredPersonality ? 1.1 : 1.0),
                          child: Text(
                            "PERSOENLICHKEITSSTUFEN",
                            style: TextStyle(
                              fontSize: screenHeight * 0.021,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Verstehe dich selbst und andere ",
                        style: TextStyle(
                          fontSize: screenHeight * 0.056,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
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
              ),
              SizedBox(width: 16.0),
              // Right column animation
              Expanded(
                flex: 1,
                child: SlideTransition(
                  position: _rightColumnAnimation!,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: screenWidth * 0.35,
                      height: screenHeight * 0.35,
                      child: Image.asset('assets/adventurer_front.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                Text(
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
