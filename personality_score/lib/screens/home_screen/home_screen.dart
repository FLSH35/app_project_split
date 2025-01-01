// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:personality_score/screens/home_screen/personality_home_mobile.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:personality_score/screens/home_desktop_layout/desktop_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../adventurer_image_desktop.dart';
import '../mobile_layout/lazy_load_image.dart';
import '../mobile_layout/mobile_video_section1.dart';
import '../mobile_layout/mobile_video_section2.dart';
import 'mobile_sidebar.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'custom_footer.dart'; // Import for the custom footer
import 'package:personality_score/helper_functions/video_helper.dart'; // Import VideoWidget

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers and Keys
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tutorialKey = GlobalKey();
  bool isLoading = false; // Loading state
  bool isLoadingTest = false; // Loading state
  // State variables
  int currentPage = 0;
  final int questionsPerPage = 7;
  final List<String> tutorialQuestions = [
    'Mit dem Schieberegler kann ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich schnell, ohne lange nachzudenken.',
    'Ich antworte ehrlich und gewissenhaft.',
  ];
  final Map<int, int> answers = {};

  // Removed pre-initialized VideoPlayerControllers
  // VideoPlayerController? _videoController1;
  // VideoPlayerController? _videoController2;

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
    // Removed _initializeVideos();
    _loadTutorialQuestions();

    // PageController infinite scrolling
    initialTestimonialPage = testimonials.length * 1000;
    selectedTestimonialIndex = initialTestimonialPage % testimonials.length;
    _testimonialPageController = PageController(
      initialPage: initialTestimonialPage,
      viewportFraction: 0.8,
    );
  }

  // Removed _initializeVideos()

  Future<void> _loadTutorialQuestions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // Removed _videoController1?.dispose();
    // Removed _videoController2?.dispose();
    _testimonialPageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFFEDE8DB),
      endDrawer: MobileSidebar(),
      appBar: isDesktop ? null : _buildAppBar(context),
      body: ScreenTypeLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildMobileLayout(context),
        desktop: DesktopLayout(), // in desktop_layout.dart
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar( title: Image.asset(
      'assets/Logo-IYC-gross.png', height: 50,
    ),
      backgroundColor: Color(0xFFF7F5EF),
      iconTheme: IconThemeData(color: Colors.black),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
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

  Widget _buildMobileLayout(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          const LazyLoadImage(
            assetPath: 'assets/ps_background_ai.jpg',
            fit: BoxFit.cover
          ),
          _buildHeaderSection(context, screenHeight, screenWidth),
          const SizedBox(height: 200),
          _buildVideoSection1(), // Updated to use MobileVideoSection1
          const SizedBox(height: 200),
          buildPersonalityTypesSection(context, screenHeight, screenWidth),
          const SizedBox(height: 200),
          isLoading ? const CircularProgressIndicator() : _buildTutorialSection(context),
          const SizedBox(height: 200),
          _buildTestimonialSection(),
          const SizedBox(height: 100),
          CustomFooter(),
        ],
      ),
    );
  }

  // HEADER
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
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: Column(
              children: [
                SelectableText(
                  "Die 8 Stufen der Persönlichkeitsentwicklung – auf welcher stehst du?",
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                SelectableText(
                  "Erhalte messerscharfe Klarheit über deinen Entwicklungsstand und erfahre, wie du das nächste Level erreichen kannst.",
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCB9935),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.10,
                      vertical: screenHeight * 0.021,
                    ),
                  ),
                  onPressed: () {
                    _scrollToTutorialSection();
                  },
                  child: Text(
                    'Mache den Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: screenHeight * 0.025,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
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
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Updated to use the new MobileVideoSection1
  Widget _buildVideoSection1() {
    return const MobileVideoSection1();
  }

  // Updated to use the new MobileVideoSection2
  Widget _buildVideoSection2() {
    return const MobileVideoSection2();
  }

  // TUTORIAL SECTION
  Widget _buildTutorialSection(BuildContext context) {
    return Container(
      key: _tutorialKey,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildVideoSection2(),
          const SizedBox(height: 40),
          _buildQuestionsList(context),
          const SizedBox(height: 40),
          _buildNavigationButton(context),
          const SizedBox(height: 40),
        ],
      ),
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
          margin: const EdgeInsets.only(bottom: 10.0),
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
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Roboto',
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 8.0),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Dummy lines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
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
                      const SizedBox(width: 12.0),
                    ],
                  ),
                  // Slider
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
                    activeColor: const Color(0xFFCB9935),
                    inactiveColor: Colors.grey,
                    thumbColor: const Color(0xFFCB9935),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildScaleLabel('NEIN'),
                    _buildScaleLabel('EHER NEIN'),
                    _buildScaleLabel('NEUTRAL'),
                    _buildScaleLabel('EHER JA'),
                    _buildScaleLabel('JA'),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScaleLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[900],
        fontSize: 12,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context) {

    return isLoadingTest
        ? SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCB9935)),
        strokeWidth: 2.0,
      ),
    )
        : ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFCB9935),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      onPressed: isLoading
          ? null
          : () async {
        setState(() {
          isLoading = true;
        });
        await handleTakeTest(context);
        setState(() {
          isLoading = false;
        });
      },
      child: Text(
        'Weiter',
        style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 20),
      ),
    );
  }

  // TESTIMONIAL
  Widget _buildTestimonialSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF7F5EF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Was unsere Nutzer sagen",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 360,
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
                        testimonials[adjustedIndex]['name'] ?? '',
                        testimonials[adjustedIndex]['text'] ?? '',
                        testimonials[adjustedIndex]['personalityType'] ?? '',
                        testimonials[adjustedIndex]['image'] ?? '',
                        isSelected,
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      if (_testimonialPageController.hasClients) {
                        _testimonialPageController.previousPage(
                          duration: const Duration(milliseconds: 300),
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
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      if (_testimonialPageController.hasClients) {
                        _testimonialPageController.nextPage(
                          duration: const Duration(milliseconds: 300),
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
          const SizedBox(height: 20),
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
    double nameFontSize = isSelected ? 18 : 16;
    double typeFontSize = isSelected ? 16 : 14;
    double textFontSize = isSelected ? 14 : 12;
    double imageSize = isSelected ? 110 : 85;

    return Container(
      width: screenWidth * 0.7,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
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
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(imageSize / 2),
            child: Image.asset(
              imagePath,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  radius: imageSize / 2,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: imageSize / 2,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 8),
          Text(
            personalityType,
            style: TextStyle(
              fontSize: typeFontSize,
              fontFamily: 'Roboto',
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
