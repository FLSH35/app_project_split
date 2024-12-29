// lib/screens/home_screen.dart
// home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:personality_score/screens/home_desktop_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'mobile_sidebar.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'custom_footer.dart'; // Import for the custom footer
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math'; // For transformations
import 'package:personality_score/helper_functions/video_helper.dart'; // Import VideoWidget

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers and Keys
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tutorialKey = GlobalKey();

  // State variables
  bool isLoading = true;
  int currentPage = 0;
  final int questionsPerPage = 7;
  final List<String> tutorialQuestions = [
    'Mit dem Schieberegler kann ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich schnell, ohne lange nachzudenken.',
    'Ich antworte ehrlich und gewissenhaft.',
  ];
  final Map<int, int> answers = {};

  // Video player controllers
  VideoPlayerController? _videoController1;
  VideoPlayerController? _videoController2;

  // Testimonial PageController
  late PageController _testimonialPageController;
  int initialTestimonialPage = 0;
  late int selectedTestimonialIndex;

  // Testimonials Data
  final List<Map<String, String>> testimonials = [
    {
      "name": "Andrés",
      "text":
      "Der Personality Score hat mir geholfen, meine Stärken besser zu erkennen und meine Ziele klarer zu definieren.",
      "image": "assets/testimonials/Andres.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Jana",
      "text":
      "Ein tolles Tool, das mir geholfen hat, einen Schritt weiter in meiner Persönlichkeitsentwicklung zu gehen.",
      "image": "assets/testimonials/Jana.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Christoph",
      "text":
      "Ich liebe die Klarheit, die der Test mir gebracht hat. Eine Bereicherung für jeden, der wachsen will!",
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
    _initializeVideos();
    _loadTutorialQuestions();

    // Initialize testimonial PageController for infinite scrolling
    initialTestimonialPage = testimonials.length * 1000;
    selectedTestimonialIndex = initialTestimonialPage % testimonials.length;
    _testimonialPageController = PageController(
      initialPage: initialTestimonialPage,
      viewportFraction: 0.8,
    );
  }

  @override
  void dispose() {
    _videoController1?.dispose();
    _videoController2?.dispose();
    _testimonialPageController.dispose();
    _scrollController.dispose();
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
  // Mobile AppBar (grey background, button for right drawer)
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'PERSONALITY SCORE',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      backgroundColor: Color(0xFFF7F5EF),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            tooltip: 'Menü öffnen',
          ),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = getValueForScreenType<bool>(
      context: context,
      mobile: false,
      tablet: false,
      desktop: true,
    );

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      endDrawer: MobileSidebar(),
      appBar: isDesktop ? null : _buildAppBar(context),
      body: ScreenTypeLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildMobileLayout(context), // Assuming tablet uses mobile layout
        desktop: DesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          SizedBox(height: 200),
          Image.asset(
              'assets/ps_background_ai.jpg',
              fit: BoxFit.cover,
              width: screenWidth,
            ),
          _buildHeaderSection(context, screenHeight, screenWidth),
          SizedBox(height: 200),
          _buildVideoSection1(),
          SizedBox(height: 200),
          _buildPersonalityTypesSection(context, screenHeight, screenWidth),
          SizedBox(height: 200),
          isLoading ? CircularProgressIndicator() : _buildTutorialSection(context),
          SizedBox(height: 200),
          _buildTestimonialSection(), // Add the testimonial section here
          SizedBox(height: 100),
          CustomFooter(),
        ],
      ),
    );
  }

  Widget _buildTestimonialSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Color(0xFFF7F5EF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Was unsere Nutzer sagen",
            style: TextStyle(
              fontSize: 24, // Adjusted for mobile
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 360, // Adjust height based on design
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _testimonialPageController,
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(() {
                        selectedTestimonialIndex = index % testimonials.length;
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    int adjustedIndex = index % testimonials.length;
                    bool isSelected = adjustedIndex == selectedTestimonialIndex;
                    return Transform.scale(
                      scale: isSelected ? 1.1 : 0.9,
                      child: _buildTestimonialCard(
                        testimonials[adjustedIndex]['name']!,
                        testimonials[adjustedIndex]['text']!,
                        testimonials[adjustedIndex]['personalityType']!,
                        testimonials[adjustedIndex]['image']!,
                        isSelected,
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      if (_testimonialPageController.hasClients) {
                        _testimonialPageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    tooltip: 'Vorherige Bewertung',
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      if (_testimonialPageController.hasClients) {
                        _testimonialPageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    tooltip: 'Nächste Bewertung',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
      String name,
      String text,
      String personalityType,
      String imagePath,
      bool isSelected,
      ) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Adjust font sizes based on selection and screen size
    double nameFontSize = isSelected ? 18 : 16;
    double typeFontSize = isSelected ? 16 : 14;
    double textFontSize = isSelected ? 14 : 12;
    double imageSize = isSelected ? 110 : 85;

    return Container(
      width: screenWidth * 0.7, // Adjusted for mobile
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
          SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(imageSize / 2), // Circular image
            child: Image.asset(
              imagePath,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  radius: imageSize / 2,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: imageSize / 2, color: Colors.white),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: nameFontSize,
              fontFamily: 'Roboto',
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            personalityType,
            style: TextStyle(
              fontSize: typeFontSize,
              fontFamily: 'Roboto',
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: textFontSize,
                fontFamily: 'Roboto',
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
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
                    fontSize: screenHeight * 0.036,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                SelectableText(
                  "Erhalte messerscharfe Klarheit über deinen Entwicklungsstand und erfahre, wie du das nächste Level erreichen kannst.",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
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
                    _scrollToTutorialSection();
                  },
                  child: Text(
                    'Zum Test',
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
    );
  }

  void _scrollToTutorialSection() {
    Scrollable.ensureVisible(
      _tutorialKey.currentContext!,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildVideoSection1() {
    return VideoWidget(
      videoController: _videoController1,
      screenHeight: MediaQuery.of(context).size.height,
      headerText: "Wieso MUSST du den Personality Score ausfüllen?",
      subHeaderText: "Erfahre es im Video!",
    );
  }

  Widget _buildVideoSection2() {
    return VideoWidget(
      videoController: _videoController2,
      screenHeight: MediaQuery.of(context).size.height,
      headerText: "Starte Hier",
      subHeaderText: "10 Minuten. 120 Fragen. Bis zu deinem Ergebnis!",
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
            horizontal: MediaQuery.of(context).size.width / 10,
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
                      if (mounted) {
                        setState(() {
                          answers[questionIndex] = val.toInt();
                        });
                      }
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NEIN',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      'EHER NEIN',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      'NEUTRAL',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      'EHER JA',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      'JA',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
        backgroundColor: Color(0xFFCB9935),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      onPressed: () {
        handleTakeTest(context);
      },
      child: Text(
        'Beginne den Test',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 18,
        ),
      ),
    );
  }

  // Personality types section
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
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              Text(
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
                  shape: RoundedRectangleBorder(
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
                    fontSize: screenHeight * 0.021,
                  ),
                ),
              ),
              SizedBox(height: 40),
              AdventurerImage(screenWidth: screenWidth, screenHeight: screenHeight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialSection(BuildContext context) {
    return Container(
      key: _tutorialKey,
      child: Column(
        children: [
          SizedBox(height: 40),
          _buildVideoSection2(),
          SizedBox(height: 40),
          _buildQuestionsList(context),
          SizedBox(height: 40),
          _buildNavigationButton(context),
          SizedBox(height: 40),
        ],
      ),
    );
  }

}




// AdventurerImage Widget with hover effect
class AdventurerImage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  AdventurerImage({required this.screenWidth, required this.screenHeight});

  @override
  _AdventurerImageState createState() => _AdventurerImageState();
}

class _AdventurerImageState extends State<AdventurerImage> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: Transform(
          transform: !isHovered ? Matrix4.identity() : Matrix4.identity()
            ..setEntry(3, 2, 0.000)
            ..rotateY(pi / 1),
          alignment: FractionalOffset.center,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: !isHovered ? widget.screenWidth * 0.7 : widget.screenWidth * 0.8,
            height: !isHovered ? widget.screenHeight * 0.35 : widget.screenHeight * 0.4,
            child: Image.asset('assets/adventurer_front.png'),
          ),
        ),
      ),
    );
  }
}