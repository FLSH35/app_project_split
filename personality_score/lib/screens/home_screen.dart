import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'home_desktop_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'mobile_sidebar.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'custom_footer.dart'; // Import for the custom footer
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers and Keys
  ScrollController _scrollController = ScrollController();
  final GlobalKey _tutorialKey = GlobalKey();

  // State variables
  bool isLoading = true;
  int currentPage = 0;
  int questionsPerPage = 7;
  List<String> tutorialQuestions = [
    'Mit dem Schieberegler kann ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich schnell, ohne lange nachzudenken.',
    'Ich antworte ehrlich und gewissenhaft.',
  ];
  Map<int, int> answers = {};

  // YouTube controllers
  late YoutubePlayerController _youtubeController;
  late YoutubePlayerController _youtubeController1;

  @override
  void initState() {
    super.initState();

    // Initialize YouTube controllers
    _youtubeController = YoutubePlayerController(
      initialVideoId: 'cu_mXjAnTqg', // First video
      params: YoutubePlayerParams(
        autoPlay: false,
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    _youtubeController1 = YoutubePlayerController(
      initialVideoId: 'fnSFCXFi69M', // Second video
      params: YoutubePlayerParams(
        autoPlay: false,
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    _loadTutorialQuestions();
  }

  Future<void> _loadTutorialQuestions() async {
    // Simulate loading delay
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _youtubeController.close();
    _youtubeController1.close();
    super.dispose();
  }

  // Mobile AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('PERSONALITY SCORE'),
      backgroundColor: Color(0xFFF7F5EF), // Light grey
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      endDrawer: MobileSidebar(),
      appBar: _buildAppBar(context),
      body: ScreenTypeLayout(
        mobile: _buildMobileLayout(screenHeight, screenWidth),
        desktop: DesktopLayout(), // Reuse desktop layout for larger screens
      ),
    );
  }

  Widget _buildMobileLayout(double screenHeight, double screenWidth) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          SizedBox(height: 250), // Adjust padding for mobile
          _buildHeaderSection(context, screenHeight, screenWidth),
          SizedBox(height: 250),
          _buildYouTubeSection(screenWidth),
          SizedBox(height: 250),
          _buildPersonalityTypesSection(context, screenHeight, screenWidth),
          SizedBox(height: 250),
          isLoading ? CircularProgressIndicator() : _buildTutorialSection(context),
          SizedBox(height: 250),
          CustomFooter(),
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
                    fontSize: screenHeight * 0.03,
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
                    'Beginne den Test',
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

  Widget _buildYouTubeSection(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Wieso MUSST du den Personality Score ausfüllen?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              width: screenWidth * 0.9,
              child: YoutubePlayerIFrame(
                controller: _youtubeController,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSection(BuildContext context) {
    return Container(
      key: _tutorialKey,
      child: Column(
        children: [
          _buildYouTubeSection1(),
          SizedBox(height: 40),
          _buildQuestionsList(context),
          SizedBox(height: 40),
          _buildNavigationButton(context),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildYouTubeSection1() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Starte Hier",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: YoutubePlayerIFrame(
                controller: _youtubeController1,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
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
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              SelectableText(
                questionText,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
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
        backgroundColor: Color(0xFFCB9935),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      onPressed: () {
        handleTakeTest(context);
      },
      child: Text('Beginne den Test'),
    );
  }

  Widget _buildPersonalityTypesSection(BuildContext context, double screenHeight, double screenWidth) {
    return Column(
      children: [
        Text(
          "PERSÖNLICHKEITSSTUFEN",
          style: TextStyle(
            fontSize: screenHeight * 0.021,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          "Verstehe dich selbst und andere",
          style: TextStyle(
            fontSize: screenHeight * 0.04,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          width: screenWidth * 0.7,
          height: screenHeight * 0.3,
          child: Image.asset('assets/adventurer_front.png'),
        ),
      ],
    );
  }
}
