// personality_types_desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/models/questionaire_model.dart';

import 'custom_app_bar.dart';

class PersonalityTypesDesktopLayout extends StatelessWidget {
  final PageController pageController = PageController(viewportFraction: 0.33);

  final List<Map<String, String>> personalityTypes = [
    {
      "name": "Stufe 1: Anonymous",
      "image": "assets/Anonymous.webp",
      "description": """Der Anonymous operiert im Verborgenen, mit einem tiefen Weitblick und unaufhaltsamer Ruhe, beeinflusst er subtil aus dem Schatten.
Sein unsichtbares Netzwerk und seine Anpassungsfähigkeit machen ihn zum verlässlichen Berater derjenigen im Rampenlicht.""",
    },
    {
      "name": "Stufe 2: Resident",
      "image": "assets/Resident.webp",
      "description": """Im ständigen Kampf mit inneren Dämonen sucht der Resident nach persönlichem Wachstum und Klarheit, unterstützt andere trotz eigener Herausforderungen.
Seine Erfahrungen und Wissen bieten Orientierung, während er nach Selbstvertrauen und Stabilität strebt.""",
    },
    {
      "name": "Stufe 3: Explorer",
      "image": "assets/Explorer.webp",
      "description": """Immer offen für neue Wege der Entwicklung, erforscht der Explorer das Unbekannte und gestaltet sein Leben aktiv.
Seine Offenheit und Entschlossenheit führen ihn zu neuen Ideen und persönlichem Wachstum.""",
    },
    {
      "name": "Stufe 4: Reacher",
      "image": "assets/Reacher.webp",
      "description": """Als Initiator der Veränderung strebt der Reacher nach Wissen und persönlicher Entwicklung, trotz der Herausforderungen und Unsicherheiten.
Seine Motivation und innere Stärke führen ihn auf den Weg des persönlichen Wachstums.""",
    },
    {
      "name": "Stufe 5: Traveller",
      "image": "assets/Traveller.webp",
      "description": """Als ständiger Abenteurer strebt der Traveller nach neuen Erfahrungen und persönlichem Wachstum, stets begleitet von Neugier und Offenheit.
Er inspiriert durch seine Entschlossenheit, das Leben in vollen Zügen zu genießen und sich kontinuierlich weiterzuentwickeln.""",
    },
    {
      "name": "Stufe 6: Individual",
      "image": "assets/Individual.webp",
      "description": """Der Individual strebt nach Klarheit und Verwirklichung seiner Ziele, beeindruckt durch Selbstbewusstsein und klare Entscheidungen.
Er inspiriert andere durch seine Entschlossenheit und positive Ausstrahlung.""",
    },
    {
      "name": "Stufe 7: Adventurer",
      "image": "assets/Adventurer.webp",
      "description": """Der Adventurer meistert das Leben mit Leichtigkeit und fasziniert durch seine Ausstrahlung und Selbstsicherheit, ein Magnet für Erfolg und Menschen.
Kreativ und strukturiert erreicht er seine Ziele in einem Leben voller spannender Herausforderungen.""",
    },
    {
      "name": "Stufe 8: Life Artist",
      "image": "assets/Life Artist.webp",
      "description": """Der Life Artist lebt seine Vision des Lebens mit Dankbarkeit und Energie, verwandelt Schwierigkeiten in bedeutungsvolle Erlebnisse.
Seine Gelassenheit und Charisma ziehen andere an, während er durch ein erfülltes Leben inspiriert.""",
    },
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: CustomAppBar(
        title: 'Personality Score',
      ),
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
                        fontSize: 60,
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
                        fontSize: 22,
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
                      fontSize: 24,
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
                      bool isOdd = index % 2 == 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Card(
                          color: Color(0xFFF7F5EF),
                          margin: EdgeInsets.all(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!isOdd)
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: SizedBox(
                                        width: 500,
                                        height: 500,
                                        child: Image.asset(type["image"]!),
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        type["name"]!,
                                        style: TextStyle(
                                          fontSize: 60,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        type["description"]!,
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOdd)
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: SizedBox(
                                        width: 500,
                                        height: 500,
                                        child: Image.asset(type["image"]!),
                                      ),
                                    ),
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
                            _handleTakeTest(context);
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
