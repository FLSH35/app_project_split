// personality_types_desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter_svg/flutter_svg.dart';
import '../helper_functions/questionnaire_helpers.dart';
import 'custom_app_bar.dart';

class PersonalityTypesDesktopLayout extends StatefulWidget {
  @override
  _PersonalityTypesDesktopLayoutState createState() => _PersonalityTypesDesktopLayoutState();
}

class _PersonalityTypesDesktopLayoutState extends State<PersonalityTypesDesktopLayout> {
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
      "image": "assets/Life Artist.webp",
      "descriptionPath": "assets/auswertungen/Life Artist.txt",
    },
  ];

  // Map to hold the loaded descriptions
  Map<String, String> loadedDescriptions = {};

  @override
  void initState() {
    super.initState();
    _loadDescriptions(); // Call the method here
  }

  // The _loadDescriptions method is placed inside the state class
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
          loadedDescriptions[name] = 'Description not available.';
        });
        print('Error loading description for $name: $e');
      }
    }
  }

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
            // Header Section
            Container(
              height: screenHeight / 3,
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
                      fontSize: 60,
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
                        fontSize: 22,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Personality Types Section
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
                      bool isOdd = index % 2 == 1;
                      String name = type['name']!;
                      String image = type['image']!;
                      String? description = loadedDescriptions[name];

                      return PersonalityTypeCard(
                        name: name,
                        image: image,
                        description: description ?? 'Loading...', // Show 'Loading...' if not yet loaded
                        isOdd: isOdd,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 350),
            // Footer Section with Background Image and Button
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
                            // Implement your handleTakeTest(context) method
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

}

class PersonalityTypeCard extends StatefulWidget {
  final String name;
  final String image;
  final String description;
  final bool isOdd;

  PersonalityTypeCard({
    required this.name,
    required this.image,
    required this.description,
    required this.isOdd,
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
      // Show only the first 45 words
      List<String> words = widget.description.split(' ');
      if (words.length > 45) {
        displayDescription = words.sublist(0, 45).join(' ') + '...';
      } else {
        displayDescription = widget.description;
      }
    }

    // Set a fixed height for the card
    double cardHeight = 600; // Adjust this value as needed

    // Define the button style
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
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
        child: SizedBox(
          height: cardHeight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isExpanded
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SelectableText(
                  widget.name,
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      displayDescription,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    setState(() {
                      isExpanded = false;
                    });
                  },
                  child: Text(
                    'Lese weniger',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.isOdd)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: 500,
                        height: 500,
                        child: Image.asset(widget.image),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SelectableText(
                        widget.name,
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: SelectableText(
                            displayDescription,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          setState(() {
                            isExpanded = true;
                          });
                        },
                        child: Text(
                          'Lese weiter',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isOdd)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: 500,
                        height: 500,
                        child: Image.asset(widget.image),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
