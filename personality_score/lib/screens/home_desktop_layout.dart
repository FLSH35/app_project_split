// desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:personality_score/helper_functions/video_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'adventurer_image_desktop.dart';
import 'custom_app_bar.dart'; // Import your custom app bar
import 'custom_footer.dart'; // Import your custom footer
import 'dart:math'; // For 3D transformations
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'package:video_player/video_player.dart';

class DesktopLayout extends StatefulWidget {
  @override
  _DesktopLayoutState createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {

  late PageController _pageController;
  late int selectedIndex;
  int initialPage = 0;

  bool isLoading = true;
  List<String> tutorialQuestions = [
    'Mit dem Schieberegler kann ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich schnell, ohne lange nachzudenken.',
    'Ich antworte ehrlich und gewissenhaft.',
  ];
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

  Map<int, int> answers = {};
  int currentPage = 0;
  int questionsPerPage = 7;

  // Controllers and Keys
  ScrollController _scrollController = ScrollController();
  final GlobalKey _tutorialKey = GlobalKey();

  // Video player controllers
  VideoPlayerController? _videoController1;
  VideoPlayerController? _videoController2;




  @override
  void initState() {
    super.initState();
    _initializeVideos();
    _loadTutorialQuestions();
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
    _videoController1?.dispose();
    _videoController2?.dispose();
    super.dispose();
  }



  Future<void> _initializeVideos() async {
    final storage = FirebaseStorage.instance;
    final gsUrl1 = 'gs://personality-score.appspot.com/Personality Score 3.mov';
    final gsUrl2 = 'gs://personality-score.appspot.com/Personality Score 1.mov'; // Replace with the correct URL if different

    try {
      // Initialize the first video controller
      String downloadUrl1 = await storage.refFromURL(gsUrl1).getDownloadURL();
      _videoController1 = VideoPlayerController.networkUrl(Uri.parse(downloadUrl1))
        ..setLooping(true)
        ..initialize().then((_) {
          setState(() {});
        });

      // Initialize the second video controller
      String downloadUrl2 = await storage.refFromURL(gsUrl2).getDownloadURL();
      _videoController2 = VideoPlayerController.networkUrl(Uri.parse(downloadUrl2))
        ..setLooping(true)
        ..initialize().then((_) {
          setState(() {});
        });
    } catch (e) {
      print('Error loading video: $e');
    }
  }

  Future<void> _loadTutorialQuestions() async {
    // Simulate loading delay
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: CustomAppBar(title: 'Personality Score'),
      body: SingleChildScrollView(
        controller: _scrollController, // Attach the scroll controller
        child: Column(
          children: [

            SizedBox(height: 350),
            _buildHeaderSection(context, screenHeight, screenWidth),
            SizedBox(height: 350),
            VideoWidget(
              videoController: _videoController1,
              screenHeight: MediaQuery.of(context).size.height,
              headerText: "Wieso MUSST du den Personality Score ausfüllen?",
              subHeaderText: "Erfahre es im Video!",
            ),
            SizedBox(height: 350),
            _buildPersonalityTypesSection(context, screenHeight, screenWidth),
            SizedBox(height: 350),
            isLoading ? CircularProgressIndicator() : _buildTutorialSection(context),
            SizedBox(height: 350),
            _buildTestimonialSection(), // Add the testimonial section here
            SizedBox(height: 100),
            CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialSection(BuildContext context) {

    return Container(
      key: _tutorialKey, // Add the key here
      child: Column(
        children: [
          SizedBox(height: 40),

          VideoWidget(
            videoController: _videoController2,
            screenHeight: MediaQuery.of(context).size.height,
            headerText: "Starte Hier",
            subHeaderText: "10 Minuten. 120 Fragen. Bis zu deinem Ergebnis!",
          ),
          SizedBox(height: 40),
          _buildQuestionsList(context),
          SizedBox(height: 40),
          _buildNavigationButton(context),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, double screenHeight, double screenWidth) {
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
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
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
                    _scrollToTutorialSection(); // Scroll to the tutorial section
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

  void _scrollToTutorialSection() {
    Scrollable.ensureVisible(
      _tutorialKey.currentContext!,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }





  Widget _buildQuestionsList(BuildContext context) {
    int start = currentPage * questionsPerPage;
    int end = start + questionsPerPage;
    List<String> currentQuestions = tutorialQuestions.sublist(
      start,
      end > tutorialQuestions.length ? tutorialQuestions.length : end,
    );

    return Column(
      children: currentQuestions.map((questionText) {
        int questionIndex = start + currentQuestions.indexOf(questionText);
        return Container(
          height: MediaQuery.of(context).size.height / 4,
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: MediaQuery.of(context).size.width / 5,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: SelectableText(
                  questionText,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Roboto',
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
              SizedBox(height: 8.0),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Row of vertical lines with margin to align with slider divisions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(11, (index) {
                              return Container(
                                width: 1,
                                height: 20,
                                color: Colors.grey,
                              );
                            }),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0),
                    ],
                  ),
                  // The slider itself
                  Slider(
                    value: (answers[questionIndex] ?? 5).toDouble(),
                    onChanged: (val) {
                      setState(() {
                        answers[questionIndex] = val.toInt();
                      });
                    },
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: Color(0xFFCB9935),
                    inactiveColor: Colors.grey,
                    thumbColor: Color(0xFFCB9935),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableText(
                    'NEIN',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SelectableText(
                    'EHER NEIN',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SelectableText(
                    'NEUTRAL',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SelectableText(
                    'EHER JA',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SelectableText(
                    'JA',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
            backgroundColor: Color(0xFFCB9935),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          onPressed: () {
            handleTakeTest(context); // Ensure this function is defined in your helpers
          },
          child: Text(
            'Beginne den Test',
            style: TextStyle(
                color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialSection() {


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


  Widget _buildPersonalityTypesSection(BuildContext context, double screenHeight, double screenWidth) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SelectableText(
                      "PERSÖNLICHKEITSSTUFEN",
                      style: TextStyle(
                        fontSize: screenHeight * 0.021,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 20),
                    SelectableText(
                      "Verstehe dich selbst und andere ",
                      style: TextStyle(
                        fontSize: screenHeight * 0.056,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 20),
                    SelectableText(
                      "Vom Anonymus zum LifeArtist: Die 8 Stufen symbolisieren die wichtigsten Etappen auf dem Weg, dein Potenzial voll auszuschöpfen. Mit einem fundierten Verständnis des Modells wirst du nicht nur dich selbst, sondern auch andere Menschen viel besser verstehen und einordnen können.",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        fontSize: screenHeight * 0.021,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 70),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCB9935),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                          vertical: screenHeight * 0.021,
                        ),
                        shape: RoundedRectangleBorder(
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
                          fontFamily: 'Roboto',
                          fontSize: screenHeight * 0.021,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AdventurerImage(screenWidth: screenWidth, screenHeight: screenHeight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
