// lib/screens/desktop_layout/desktop_header_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopHeaderSection extends StatelessWidget {
  const DesktopHeaderSection({Key? key}) : super(key: key);

  void _scrollToTutorialSection(BuildContext context, GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

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
                  "Erhalte messerscharfe Klarheit ...",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 50),
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
                    // Hier könntest du den TutorialKey nutzen,
                    // der in DesktopTutorialSection definiert ist (per GlobalKey).
                    // _scrollToTutorialSection(context, tutorialKey);
                  },
                  child: Text(
                    'Zum Test',
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
}
