import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget buildPersonalityTypesSection(BuildContext context, double screenHeight, double screenWidth) {
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "PERSÖNLICHKEITSSTUFEN",
              style: TextStyle(
                fontSize: screenHeight * 0.021,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Verstehe dich selbst und andere",
              style: TextStyle(
                fontSize: screenHeight * 0.056,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Vom Anonymus zum LifeArtist: Die 8 Stufen symbolisieren die wichtigsten Etappen auf dem Weg, dein Potenzial voll auszuschöpfen. Mit einem fundierten Verständnis des Modells wirst du nicht nur dich selbst, sondern auch andere Menschen viel besser verstehen und einordnen können.",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Roboto',
                fontSize: screenHeight * 0.021,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCB9935),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                'Erfahre mehr',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontSize: screenHeight * 0.025,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Image.asset('assets/adventurer_front.png', height: 300,)
          ],
        ),
      ),
    ],
  );
}