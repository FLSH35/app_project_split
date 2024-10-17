// personality_types_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für rootBundle
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'personality_types_desktop_layout.dart'; // Importiere das Desktop-Layout
import 'mobile_sidebar.dart'; // Importiere die mobile Sidebar

class PersonalityTypesPage extends StatefulWidget {
  @override
  _PersonalityTypesPageState createState() => _PersonalityTypesPageState();
}

class _PersonalityTypesPageState extends State<PersonalityTypesPage> {
  final List<Map<String, String>> personalityTypes = [
    {
      "name": "Stufe 1: Anonymous",
      "image": "assets/Anonymous.webp",
      "descriptionPath": "assets/auswertungen/Anonymous.txt",
    },
    {
      "name": "Stufe 2: Resident",
      "image": "assets/Resident_woman.jpg",
      "descriptionPath": "assets/auswertungen/Resident.txt",
    },
    {
      "name": "Stufe 3: Explorer",
      "image": "assets/Explorer.webp",
      "descriptionPath": "assets/auswertungen/Explorer.txt",
    },
    {
      "name": "Stufe 4: Reacher",
      "image": "assets/Reacher_woman.jpg",
      "descriptionPath": "assets/auswertungen/Reacher.txt",
    },
    {
      "name": "Stufe 5: Traveller",
      "image": "assets/Traveller.webp",
      "descriptionPath": "assets/auswertungen/Traveller.txt",
    },
    {
      "name": "Stufe 6: Individual",
      "image": "assets/Individual.webp",
      "descriptionPath": "assets/auswertungen/Individual.txt",
    },
    {
      "name": "Stufe 7: Adventurer",
      "image": "assets/Adventurer.webp",
      "descriptionPath": "assets/auswertungen/Adventurer.txt",
    },
    {
      "name": "Stufe 8: Life Artist",
      "image": "assets/LifeArtist.webp",
      "descriptionPath": "assets/auswertungen/Life Artist.txt",
    },
  ];

  // Map zum Speichern der geladenen Beschreibungen
  Map<String, String> loadedDescriptions = {};

  @override
  void initState() {
    super.initState();
    _loadDescriptions(); // Beschreibungen laden
  }

  // Methode zum Laden der Beschreibungen aus den .txt-Dateien
  Future<void> _loadDescriptions() async {
    for (var type in personalityTypes) {
      String name = type['name']!;
      String path = type['descriptionPath']!;
      try {
        String description = await rootBundle.loadString(path);
        setState(() {
          loadedDescriptions[name] = description;
        });
      } catch (e) {
        setState(() {
          loadedDescriptions[name] = 'Beschreibung nicht verfügbar.';
        });
        print('Fehler beim Laden der Beschreibung für $name: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context), // Mobiles Layout
      desktop: PersonalityTypesDesktopLayout(), // Desktop-Layout
    );
  }

  // Mobiles Layout
  Widget _buildMobileLayout(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      endDrawer: MobileSidebar(), // Mobile Sidebar
      appBar: _buildAppBar(context), // AppBar für Mobile
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header-Bereich
            Container(
              height: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText(
                    "Die 8 Persönlichkeitsstufen",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40, // Angepasste Schriftgröße für Mobile
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SelectableText(
                      "Lerne das Modell kennen.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, // Angepasste Schriftgröße für Mobile
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Persönlichkeits-Typen
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Column(
                    children: personalityTypes.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> type = entry.value;
                      String name = type['name']!;
                      String image = type['image']!;
                      String? description = loadedDescriptions[name];

                      return PersonalityTypeCard(
                        name: name,
                        image: image,
                        description: description ?? 'Lädt...', // Zeige 'Lädt...' wenn noch nicht geladen
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            // Footer mit Hintergrundbild und Button
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
                        SelectableText(
                          "Die 8 Stufen der Persönlichkeitsentwicklung – auf welcher stehst du?",
                          style: TextStyle(
                            fontSize: screenHeight * 0.035, // Angepasst für Mobile
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
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // AppBar für Mobile mit Menü-Button
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: SelectableText(
        'STUFEN',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Color(0xFFF7F5EF),
      iconTheme: IconThemeData(color: Colors.black),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer(); // Öffne die Sidebar
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false, // Entferne den Zurück-Button für Mobile
    );
  }

  // Implementiere deine handleTakeTest-Methode
  void handleTakeTest(BuildContext context) {
    // Navigiere zur Testseite oder implementiere die gewünschte Funktionalität
  }
}

class PersonalityTypeCard extends StatefulWidget {
  final String name;
  final String image;
  final String description;

  PersonalityTypeCard({
    required this.name,
    required this.image,
    required this.description,
  });

  @override
  _PersonalityTypeCardState createState() => _PersonalityTypeCardState();
}

class _PersonalityTypeCardState extends State<PersonalityTypeCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String displayDescription;
    if (isExpanded) {
      displayDescription = widget.description;
    } else {
      // Zeige nur die ersten 30 Wörter
      List<String> words = widget.description.split(' ');
      if (words.length > 30) {
        displayDescription = words.sublist(0, 30).join(' ') + '...';
      } else {
        displayDescription = widget.description;
      }
    }

    // Definiere den Button-Stil
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isExpanded ? Colors.black : Color(0xFFCB9935),
      side: BorderSide(color: Color(0xFFCB9935)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );

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
                widget.image,
                width: MediaQuery.of(context).size.width * 0.7,
                height: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              SelectableText(
                widget.name,
                style: TextStyle(
                  fontSize: 30, // Angepasste Schriftgröße für Mobile
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              // Scrollbarer Bereich für die Beschreibung
              isExpanded
                  ? Container(
                height: 200, // Festgelegte Höhe für den scrollbaren Bereich
                child: SingleChildScrollView(
                  child: SelectableText(
                    displayDescription,
                    style: TextStyle(
                      fontSize: 18, // Angepasste Schriftgröße für Mobile
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : SelectableText(
                displayDescription,
                style: TextStyle(
                  fontSize: 18, // Angepasste Schriftgröße für Mobile
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? 'Lese weniger' : 'Lese mehr',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
