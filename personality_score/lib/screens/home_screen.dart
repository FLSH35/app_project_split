import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'home_desktop_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:personality_score/models/questionaire_model.dart';
import 'mobile_sidebar.dart'; // Import the new MobileSidebar
import 'package:personality_score/auth/auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      endDrawer: MobileSidebar(), // Use MobileSidebar for mobile
      appBar: getValueForScreenType<bool>(
        context: context,
        mobile: false, // No app bar for mobile
        desktop: true,  // App bar only for desktop
      )
          ? null  // Build desktop app bar
          : _buildAppBar(context), // No app bar for mobile
      body: ScreenTypeLayout(
        mobile: _buildMobileLayout(),
        desktop: DesktopLayout(), // Desktop uses the layout from desktop_layout.dart
      ),
    );
  }


  // Mobile AppBar (grey background, button for right drawer)
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Personality Score'),
      backgroundColor: Colors.grey[300], // Light grey for mobile
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu), // Menu icon to open the right-side drawer for mobile
            onPressed: () {
              Scaffold.of(context).openEndDrawer(); // Open the right-side drawer for mobile
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false, // Remove back button for mobile
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 350),
          _buildHeaderSection(MediaQuery.of(context).size.width),
          SizedBox(height: 350),
          _buildPersonalityTypesSection(context,
              MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
          SizedBox(height: 350),
          _buildCuriousSection(context, MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
          SizedBox(height: 350),
        ],
      ),
    );
  }

  // Header section for both mobile and desktop
  Widget _buildHeaderSection(double screenWidth) {
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
                    fontSize: MediaQuery.of(context).size.height * 0.042,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCB9935),
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.07,
                      vertical: MediaQuery.of(context).size.height * 0.021,
                    ),
                  ),
                  onPressed: () {
                    _handleTakeTest(context); // Call to the test function
                  },
                  child: Text(
                    'Take the Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.height * 0.021,
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

  // Personality types section for both mobile and desktop
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text Section
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
                textAlign: TextAlign.center,
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

              // Learn More Button
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

              // Image Section (moved below the text for mobile)
              SizedBox(height: 40),
              SizedBox(
                width: screenWidth * 0.7, // Adjusted size for mobile
                height: screenHeight * 0.35,
                child: Image.asset('assets/adventurer_front.png'),
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
