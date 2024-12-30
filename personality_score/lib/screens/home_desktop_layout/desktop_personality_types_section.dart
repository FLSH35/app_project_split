// lib/screens/desktop_layout/desktop_personality_types_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../adventurer_image_desktop.dart';

class DesktopPersonalityTypesSection extends StatelessWidget {
  const DesktopPersonalityTypesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left column
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "PERSÖNLICHKEITSSTUFEN",
                      style: TextStyle(
                        fontSize: screenHeight * 0.021,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Verstehe dich selbst und andere ",
                      style: TextStyle(
                        fontSize: screenHeight * 0.056,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Vom Anonymus zum LifeArtist: ...",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenHeight * 0.021,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 70),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCB9935),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                          vertical: screenHeight * 0.021,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/personality_types');
                      },
                      child: Text(
                        'Erfahre mehr',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.021,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              // Right column (Adventurer Image)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AdventurerImage(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
