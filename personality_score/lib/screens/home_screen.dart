import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'home_desktop_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:personality_score/models/questionaire_model.dart';
import 'mobile_sidebar.dart'; // Import the new MobileSidebar
import 'package:personality_score/auth/auth_service.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'custom_footer.dart'; // Import for the custom footer

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
      title: Text('PERSONALITY SCORE'),
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
          _buildCuriousSection(context, MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
          SizedBox(height: 350),
          _buildPersonalityTypesSection(context,
              MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
          SizedBox(height: 350),
          _buildCuriousSection(context, MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
          SizedBox(height: 350),
          CustomFooter(), // Added CustomFooter at the bottom
        ],
      ),
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
                "PERSOENLICHKEITSSTUFEN",
                style: TextStyle(
                  fontSize: screenHeight * 0.021,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Roboto',
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
                textAlign: TextAlign.center,
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

              // Learn More Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCB9935),
                  shape: RoundedRectangleBorder( // Create square corners
                    borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
                  ),
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
                  "Die 8 Stufen der Persönlichkeitsentwicklung – auf welcher stehst du?",
                  style: TextStyle(
                    fontSize: screenHeight * 0.036,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCB9935),
                    shape: RoundedRectangleBorder( // Create square corners
                      borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
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
