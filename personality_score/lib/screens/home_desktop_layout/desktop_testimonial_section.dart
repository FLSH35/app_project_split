// lib/screens/desktop_layout/desktop_testimonial_section.dart
import 'package:flutter/material.dart';

class DesktopTestimonialSection extends StatefulWidget {
  const DesktopTestimonialSection({Key? key}) : super(key: key);

  @override
  State<DesktopTestimonialSection> createState() => _DesktopTestimonialSectionState();
}

class _DesktopTestimonialSectionState extends State<DesktopTestimonialSection> {
  late PageController _pageController;
  late int selectedIndex;

  int initialPage = 0;
  final List<Map<String, String>> testimonials = [
    {
      "name": "Andrés",
      "text": "Der Personality Score hat mir geholfen, meine Stärken besser zu erkennen und meine Ziele klarer zu definieren.",
      "image": "assets/testimonials/Andres.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Jana",
      "text": "Ein tolles Tool, das mir geholfen hat, einen Schritt weiter in meiner Persönlichkeitsentwicklung zu gehen.",
      "image": "assets/testimonials/Jana.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Christoph",
      "text": "Ich liebe die Klarheit, die der Test mir gebracht hat. Eine Bereicherung für jeden, der wachsen will!",
      "image": "assets/testimonials/Christoph.jpg",
      "personalityType": "Individual",
    },
    {
      "name": "Alex",
      "text": "Endlich ein Persönlichkeitstest, der mir weiterhilft.",
      "image": "assets/testimonials/Alex.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Klaus",
      "text": "Woher kennt er mich so gut?",
      "image": "assets/testimonials/Klaus.jpg",
      "personalityType": "Individual",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: testimonials.length * 1000,
      viewportFraction: 0.4,
    );

    // Set initialPage to a large value to simulate infinite scrolling
    initialPage = testimonials.length * 1000;
    selectedIndex = initialPage % testimonials.length;
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.4,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Keep track of the selected index
        int selectedIndex = initialPage % testimonials.length;

        return Container(
          padding: EdgeInsets.all(16.0),
          color: Color(0xFFF7F5EF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Was unsere Nutzer sagen",
                style: TextStyle(
                  fontSize: 28, // Larger font size for the section title
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 450, // Adjust height based on design
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          // Update selectedIndex using modulo to wrap around
                          selectedIndex = index % testimonials.length;
                        });
                      },
                      // Set itemCount to null for infinite scrolling
                      itemBuilder: (context, index) {
                        // Adjust index to wrap around using modulo
                        int adjustedIndex = index % testimonials.length;
                        return Align(
                          alignment: Alignment.center,
                          child: _buildTestimonialCard(
                              testimonials[adjustedIndex]['name']!,
                              testimonials[adjustedIndex]['text']!,
                              testimonials[adjustedIndex]['personalityType']!,
                              testimonials[adjustedIndex]['image']!

                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          if (_pageController.hasClients) {
                            _pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          if (_pageController.hasClients) {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestimonialCard(
      String name,
      String text,
      String personalityType,
      String imagePath,
      ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Dynamische Größen basierend auf der Bildschirmgröße
    double cardWidth = screenWidth *0.25; // 25% der Bildschirmbreite
    double imageSize = (cardWidth * 0.4); // 40% der Card-Breite, 25% kleiner

    return SizedBox(
      width: cardWidth,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(imageSize / 2),
              child: Image.asset(
                imagePath,
                width: imageSize, // Verkleinertes Bild
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.01875 * 1.35, // 25% größere Schriftgröße
                fontFamily: 'Roboto',
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3),
            Text(
              personalityType,
              style: TextStyle(
                fontSize: screenHeight * 0.0125 * 1.35, // 25% größere Schriftgröße
                fontFamily: 'Roboto',
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: screenHeight * 0.01 * 1.4, // 25% größere Schriftgröße
                  fontFamily: 'Roboto',
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
