// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:personality_score/screens/home_screen/personality_home_mobile.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:personality_score/screens/home_desktop_layout/desktop_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:personality_score/screens/home_screen/testimonial_card.dart';
import '../mobile_layout/lazy_load_image.dart';
import '../mobile_layout/mobile_video_section1.dart';
import '../mobile_layout/mobile_video_section2.dart';
import 'mobile_sidebar.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'custom_footer.dart'; // Import for the custom footer

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
    'Ich kann meine Zeit frei einteilen, ohne dass mein Business darunter leidet.',
    'Ich fühle mich mental frei und ohne ständigen Druck.',
    'Ich habe eine klare Strategie, um finanzielle und zeitliche Freiheit zu erreichen.',
  ];
  final Map<int, int> answers = {};

  // Testimonial PageController
  late PageController _testimonialPageController;
  int initialTestimonialPage = 0;
  late int selectedTestimonialIndex;

  // Für das “pseudo-endlose” Karussell
  static const int infiniteItemCount = 10000;

  // Testimonials Data
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
    _loadTutorialQuestions();

    // PageController infinite scrolling
    initialTestimonialPage = testimonials.length * 1000;
    selectedTestimonialIndex = initialTestimonialPage % testimonials.length;
    _testimonialPageController = PageController(
      initialPage: initialTestimonialPage,
      viewportFraction: 0.8, // Für mobile geeignet
    );
  }

  Future<void> _loadTutorialQuestions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
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
    return AppBar(
      title: Image.asset(
        'assets/Logo-IYC-gross.png',
        height: 50,
      ),
      backgroundColor: const Color(0xFFF7F5EF),
      iconTheme: const IconThemeData(color: Colors.black),
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
            fit: BoxFit.cover,
          ),
          _buildHeaderSection(context, screenHeight, screenWidth),
          const SizedBox(height: 200),
          _buildVideoSection1(), // Updated to use MobileVideoSection1
          const SizedBox(height: 200),
          buildPersonalityTypesSection(context, screenHeight, screenWidth),
          const SizedBox(height: 200),
          _buildTutorialSection(context),
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
                  "Personality Score – Dein Weg zu finanzieller und zeitlicher Freiheit",
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                SelectableText(
                  "Finde heraus, wie du dein Business so steuerst, dass es dir dient – und nicht umgekehrt. Mehr Zeit, weniger Stress, echte Kontrolle.",
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
                    'Starte jetzt',
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
        ? const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCB9935)),
        strokeWidth: 2.0,
      ),
    )
        : ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCB9935),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      onPressed: isLoadingTest
          ? null
          : () async {
        setState(() {
          isLoadingTest = true;
        });
        await handleTakeTest(context);
        setState(() {
          isLoadingTest = false;
        });
      },
      child: const Text(
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
            "Was Unternehmer wie du sagen",
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
            child: PageView.builder(
              controller: _testimonialPageController,
              // Wir verwenden infiniteItemCount für “endloses” Blättern
              itemCount: infiniteItemCount,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    selectedTestimonialIndex = index % testimonials.length;
                  });
                }
              },
              itemBuilder: (context, index) {
                // Tatsächlicher Index in der Testimonials-Liste
                int adjustedIndex = index % testimonials.length;
                bool isSelected = adjustedIndex == selectedTestimonialIndex;

                return TestimonialCard(
                  name: testimonials[adjustedIndex]['name'] ?? '',
                  text: testimonials[adjustedIndex]['text'] ?? '',
                  personalityType: testimonials[adjustedIndex]['personalityType'] ?? '',
                  imagePath: testimonials[adjustedIndex]['image'] ?? '',
                  isSelected: isSelected,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}