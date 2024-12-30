// lib/screens/desktop_layout/desktop_testimonial_section.dart
import 'package:flutter/material.dart';

class DesktopTestimonialSection extends StatefulWidget {
  const DesktopTestimonialSection({Key? key}) : super(key: key);

  @override
  State<DesktopTestimonialSection> createState() => _DesktopTestimonialSectionState();
}

class _DesktopTestimonialSectionState extends State<DesktopTestimonialSection> {
  late PageController _pageController;

  final List<Map<String, String>> testimonials = [
    {
      "name": "Andrés",
      "text": "Der Personality Score hat mir geholfen ...",
      "image": "assets/testimonials/Andres.jpg",
      "personalityType": "Traveller",
    },
    // ...
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: testimonials.length * 1000,
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
    return Container(
      color: const Color(0xFFF7F5EF),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Was unsere Nutzer sagen",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 450,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    int adjustedIndex = index % testimonials.length;
                    return _buildTestimonialCard(testimonials[adjustedIndex]);
                  },
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
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

  Widget _buildTestimonialCard(Map<String, String> data) {
    return Center(
      child: Container(
        width: 350,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(data['image']!),
            ),
            const SizedBox(height: 6),
            Text(
              data['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            Text(
              data['personalityType']!,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                data['text']!,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
