import 'dart:math';

import 'package:flutter/material.dart';

class DesktopTestimonialSection extends StatefulWidget {
  const DesktopTestimonialSection({Key? key}) : super(key: key);

  @override
  State<DesktopTestimonialSection> createState() =>
      _DesktopTestimonialSectionState();
}

class _DesktopTestimonialSectionState extends State<DesktopTestimonialSection> {
  late PageController _pageController;
  late int selectedIndex;

  int initialPage = 0;

  final List<Map<String, String>> testimonials = [
    {
      "name": "Andrés",
      "text":
      "Der Personality Score hat mir gezeigt, wie ich mein Business so aufbaue, dass ich endlich Zeit für mich habe.",
      "image": "assets/testimonials/Andres.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Jana",
      "text":
      "Ein Gamechanger! Ich habe gelernt, wie ich weniger arbeite und trotzdem mehr erreiche.",
      "image": "assets/testimonials/Jana.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Christoph",
      "text":
      "Dank Personality Score habe ich die Kontrolle zurück – über meine Zeit und mein Business.",
      "image": "assets/testimonials/Christoph.jpg",
      "personalityType": "Individual",
    },
    {
      "name": "Alex",
      "text": "Endlich ein Tool, das Unternehmern echte Freiheit bringt.",
      "image": "assets/testimonials/Alex.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Klaus",
      "text": "Es hat mir die Augen geöffnet, wie ich Stress reduziere und freier lebe.",
      "image": "assets/testimonials/Klaus.jpg",
      "personalityType": "Individual",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set initialPage to a large value to simulieren "endloses" Blättern
    initialPage = testimonials.length * 1000;
    selectedIndex = initialPage % testimonials.length;

    _pageController = PageController(
      initialPage: initialPage,
      // Wenn du mehr oder weniger Karten auf einmal zeigen willst,
      // passe die viewportFraction an. 0.4 ~ ca. 2-3 Karten
      viewportFraction: 0.2,
    );
  }

  double mapWidthToValue() {
    const double stepValue = 0.2;
    const int steps = 5;
    double currentWidth = MediaQuery.of(context).size.width;
    double idealWidth = 2560; // Beispiel für eine 27-Zoll-Bildschirmbreite in Pixeln
    // Berechne die Schrittgröße
    double stepSize = idealWidth / steps;

    // Berechne die aktuelle Schrittzahl
    int stepNumber = (currentWidth / stepSize).floor();

    // Wenn es einen Rest gibt, erhöhe die Schrittzahl um 1
    if (currentWidth % stepSize != 0 && stepNumber < steps) {
      stepNumber += 1;
    }

    // Stelle sicher, dass die Schrittzahl innerhalb des gültigen Bereichs liegt
    stepNumber = stepNumber.clamp(1, steps);

    // Mappe die Schrittzahl auf den entsprechenden Wert
    return stepValue * stepNumber;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTestimonialCard(
      String name,
      String text,
      String personalityType,
      String imagePath,
      ) {
    return _HoverableTestimonialCard(
      name: name,
      text: text,
      personalityType: personalityType,
      imagePath: imagePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF7F5EF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "WAS UNTERNEHMER WIE DU SAGEN",
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Roboto',
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 450, // Höhe entsprechend deinem Design
            child: Stack(
              alignment: Alignment.center,
              children: [
                // PageView zum Blättern durch Testimonials
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      selectedIndex = index % testimonials.length;
                    });
                  },
                  itemBuilder: (context, index) {
                    int adjustedIndex = index % testimonials.length;
                    return Align(
                      alignment: Alignment.center,
                      child: _buildTestimonialCard(
                        testimonials[adjustedIndex]['name']!,
                        testimonials[adjustedIndex]['text']!,
                        testimonials[adjustedIndex]['personalityType']!,
                        testimonials[adjustedIndex]['image']!,
                      ),
                    );
                  },
                ),
                // Pfeil nach links
                Positioned(
                  left: 20, // ein wenig nach innen gerückt
                  child: IconButton(
                    iconSize: 100, // größerer Button
                    icon: const Icon(Icons.arrow_back_ios, size: 48),
                    splashRadius: 28, // Klick-Fläche bei Bedarf anpassen
                    onPressed: () {
                      if (_pageController.hasClients) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
                // Pfeil nach rechts
                Positioned(
                  right: 20, // ein wenig nach innen gerückt
                  child: IconButton(
                    iconSize: 48,
                    icon: const Icon(Icons.arrow_forward_ios, size: 48),
                    splashRadius: 28,
                    onPressed: () {
                      if (_pageController.hasClients) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

///
/// Dieses Widget kümmert sich um den Hover-Effekt.
///
class _HoverableTestimonialCard extends StatefulWidget {
  final String name;
  final String text;
  final String personalityType;
  final String imagePath;

  const _HoverableTestimonialCard({
    Key? key,
    required this.name,
    required this.text,
    required this.personalityType,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<_HoverableTestimonialCard> createState() =>
      _HoverableTestimonialCardState();
}

class _HoverableTestimonialCardState extends State<_HoverableTestimonialCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isHovering ? screenHeight * 0.6 : screenHeight * 0.5,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
          image: DecorationImage(
            image: AssetImage(widget.imagePath),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isHovering ? 450 * 1 : 450 * 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white.withOpacity(0.6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        color: Colors.black,
                        fontSize: screenHeight * 0.023,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.personalityType,
                      style: TextStyle(
                        fontSize: screenHeight * 0.020,
                        fontFamily: 'Roboto',
                        color: Colors.grey[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize:
                        _isHovering ? screenHeight * 0.019 : screenHeight * 0.0135,
                        fontFamily: 'Roboto',
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.clip,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}