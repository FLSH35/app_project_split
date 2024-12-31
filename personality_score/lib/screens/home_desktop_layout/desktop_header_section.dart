// lib/screens/desktop_layout/desktop_header_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DesktopHeaderSection extends StatefulWidget {
  final GlobalKey videoSection2Key;

  const DesktopHeaderSection({Key? key, required this.videoSection2Key})
      : super(key: key);

  @override
  State<DesktopHeaderSection> createState() => _DesktopHeaderSectionState();
}

class _DesktopHeaderSectionState extends State<DesktopHeaderSection> {
  bool _hasRevealed = false;

  void _scrollToVideoSection2(BuildContext context) {
    if (widget.videoSection2Key.currentContext != null) {
      Scrollable.ensureVisible(
        widget.videoSection2Key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return VisibilityDetector(
      key: const Key('DesktopHeaderSection-VisibilityKey'),
      onVisibilityChanged: (visibilityInfo) {
        // If at least 10% of this widget is visible on screen, reveal the SVG
        if (visibilityInfo.visibleFraction > 0.1 && !_hasRevealed) {
          setState(() {
            _hasRevealed = true;
          });
        }
      },
      child: _hasRevealed
          ? _buildRevealedContent(screenHeight, screenWidth)
          : SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildRevealedContent(double screenHeight, double screenWidth) {
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
                  "Erhalte messerscharfe Klarheit über deinen Entwicklungsstand und erfahre, wie du das nächste Level erreichen kannst.",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
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
                  onPressed: () => _scrollToVideoSection2(context),
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
