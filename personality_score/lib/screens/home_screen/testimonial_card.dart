
import 'package:flutter/material.dart';

///
/// Einzelne Testimonial-Karte mit animierter Box – genau wie Desktop:
/// Text ist immer sichtbar, Box fährt beim Tap hoch und vergrößert den Text.
///
class TestimonialCard extends StatefulWidget {
  final String name;
  final String text;
  final String personalityType;
  final String imagePath;
  final bool isSelected;

  const TestimonialCard({
    Key? key,
    required this.name,
    required this.text,
    required this.personalityType,
    required this.imagePath,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<TestimonialCard> {
  bool _isExpanded = false;

  // Höhe der Karte
  static const double cardHeight = 340;

  // Graue Box – zusammengeklappt vs. ausgeklappt
  static const double collapsedBoxHeight = cardHeight/2;      // Immer etwas Text sichtbar
  static const double expandedBoxHeight = cardHeight; // Deckt das ganze Bild

  // Schriftgrößen (zusammengeklappt vs. ausgeklappt)
  static const double collapsedNameSize = 18;
  static const double expandedNameSize = 26;

  static const double collapsedTypeSize = 14;
  static const double expandedTypeSize = 20;

  static const double collapsedTextSize = 16;
  static const double expandedTextSize = 22;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Abhängig vom Zustand die Schriftgrößen festlegen
    final nameFontSize = _isExpanded ? expandedNameSize : collapsedNameSize;
    final typeFontSize = _isExpanded ? expandedTypeSize : collapsedTypeSize;
    final textFontSize = _isExpanded ? expandedTextSize : collapsedTextSize;

    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Hintergrundbild (oben fixiert, unten ggf. beschnitten)
            ClipRRect(
              child: Image.asset(
                widget.imagePath,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.topCenter,
                fit: BoxFit.cover, // nur unten schneiden
              ),
            ),
            // Graue Box, fährt hoch und deckt das ganze Bild ab
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: 0,
              height: _isExpanded ? expandedBoxHeight : collapsedBoxHeight,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.6),
                ),
                child: SingleChildScrollView(
                  physics: _isExpanded
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                          fontSize: nameFontSize,
                        ),
                      ),
                      Text(
                        widget.personalityType,
                        style: TextStyle(
                          fontSize: typeFontSize,
                          fontFamily: 'Roboto',
                          color: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: textFontSize,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                        ),
                        maxLines: _isExpanded ? null : 3,
                        overflow:
                        _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
