import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'personality_types_desktop_layout.dart'; // Import the desktop layout
import 'mobile_sidebar.dart'; // Import the mobile sidebar
import 'package:personality_score/models/questionaire_model.dart'; // Import your QuestionnaireModel
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';

class PersonalityTypesPage extends StatefulWidget {
  @override
  _PersonalityTypesPageState createState() => _PersonalityTypesPageState();
}

class _PersonalityTypesPageState extends State<PersonalityTypesPage> {
  final PageController _pageController = PageController(viewportFraction: 0.33);

  final List<Map<String, String>> personalityTypes = [
    {
      "name": "Anonymous",
      "image": "assets/Anonymous.webp",
      "description": """Der Anonymous operiert im Verborgenen, mit einem tiefen Weitblick und unaufhaltsamer Ruhe, beeinflusst er subtil aus dem Schatten.
Sein unsichtbares Netzwerk und seine Anpassungsfähigkeit machen ihn zum verlässlichen Berater derjenigen im Rampenlicht.""",
    },
    {
      "name": "Resident",
      "image": "assets/Resident.webp",
      "description": """Im ständigen Kampf mit inneren Dämonen sucht der Resident nach persönlichem Wachstum und Klarheit, unterstützt andere trotz eigener Herausforderungen.
Seine Erfahrungen und Wissen bieten Orientierung, während er nach Selbstvertrauen und Stabilität strebt.""",
    },
    {
      "name": "Explorer",
      "image": "assets/Explorer.webp",
      "description": """Immer offen für neue Wege der Entwicklung, erforscht der Explorer das Unbekannte und gestaltet sein Leben aktiv.
Seine Offenheit und Entschlossenheit führen ihn zu neuen Ideen und persönlichem Wachstum.""",
    },
    {
      "name": "Reacher",
      "image": "assets/Reacher.webp",
      "description": """Als Initiator der Veränderung strebt der Reacher nach Wissen und persönlicher Entwicklung, trotz der Herausforderungen und Unsicherheiten.
Seine Motivation und innere Stärke führen ihn auf den Weg des persönlichen Wachstums.""",
    },
    {
      "name": "Traveller",
      "image": "assets/Traveller.webp",
      "description": """Als ständiger Abenteurer strebt der Traveller nach neuen Erfahrungen und persönlichem Wachstum, stets begleitet von Neugier und Offenheit.
Er inspiriert durch seine Entschlossenheit, das Leben in vollen Zügen zu genießen und sich kontinuierlich weiterzuentwickeln.""",
    },
    {
      "name": "Individual",
      "image": "assets/Individual.webp",
      "description": """Der Individual strebt nach Klarheit und Verwirklichung seiner Ziele, beeindruckt durch Selbstbewusstsein und klare Entscheidungen.
Er inspiriert andere durch seine Entschlossenheit und positive Ausstrahlung.""",
    },
    {
      "name": "Adventurer",
      "image": "assets/Adventurer.webp",
      "description": """Der Adventurer meistert das Leben mit Leichtigkeit und fasziniert durch seine Ausstrahlung und Selbstsicherheit, ein Magnet für Erfolg und Menschen.
Kreativ und strukturiert erreicht er seine Ziele in einem Leben voller spannender Herausforderungen.""",
    },
    {
      "name": "Life Artist",
      "image": "assets/Life Artist.webp",
      "description": """Der Life Artist lebt seine Vision des Lebens mit Dankbarkeit und Energie, verwandelt Schwierigkeiten in bedeutungsvolle Erlebnisse.
Seine Gelassenheit und Charisma ziehen andere an, während er durch ein erfülltes Leben inspiriert.""",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context), // Mobile layout
      desktop: PersonalityTypesDesktopLayout(), // Desktop layout
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      endDrawer: MobileSidebar(), // Use the mobile sidebar
      appBar: _buildAppBar(context), // Add AppBar for mobile
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Text(
                      "What is your type?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40, // Adjust font size for mobile
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Discover what makes you special.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, // Adjust font size for mobile
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "PERSONALITY TYPES",
                    style: TextStyle(
                      fontSize: 22, // Adjust font size for mobile
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: personalityTypes.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> type = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Card(
                          color: Color(0xFFF7F5EF),
                          margin: EdgeInsets.all(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  type["image"]!,
                                  width: screenWidth * 0.5,
                                  height: screenHeight * 0.3,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  type["name"]!,
                                  style: TextStyle(
                                    fontSize: 30, // Adjust font size for mobile
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  type["description"]!,
                                  style: TextStyle(
                                    fontSize: 18, // Adjust font size for mobile
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 350),
            Stack(
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
                          "Curious how accurate we are about you?",
                          style: TextStyle(
                            fontSize: screenHeight * 0.042, // Adjust for mobile
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
            ),
            SizedBox(height: 350),
          ],
        ),
      ),
    );
  }

  // Build Mobile AppBar with a menu button to open the sidebar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Personality Types'),
      backgroundColor: Colors.grey[300],
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer(); // Open the sidebar
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false, // Remove back button for mobile
    );
  }

}
