// desktop_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'custom_app_bar.dart'; // Import your custom app bar
import 'custom_footer.dart'; // Import your custom footer
import 'dart:math'; // For 3D transformations
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
class DesktopLayout extends StatefulWidget {
  @override
  _DesktopLayoutState createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  bool isLoading = true;
  List<String> tutorialQuestions = [
    'Mit dem Schieberegler kann ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich schnell, ohne lange nachzudenken.',
    'Ich antworte ehrlich und gewissenhaft.',
  ];
  Map<int, int> answers = {};
  int currentPage = 0;
  int questionsPerPage = 7;

  // Controllers and Keys
  ScrollController _scrollController = ScrollController();
  final GlobalKey _tutorialKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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
            _buildYouTubeSection(),
            SizedBox(height: 350),
            _buildPersonalityTypesSection(context, screenHeight, screenWidth),
            SizedBox(height: 350),
            isLoading ? CircularProgressIndicator() : _buildTutorialSection(context),
            SizedBox(height: 350),
            CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialSection(BuildContext context) {
    int totalSteps = (tutorialQuestions.length / questionsPerPage).ceil();
    int currentStep = currentPage;

    return Container(
      key: _tutorialKey, // Add the key here
      child: Column(
        children: [
          SizedBox(height: 40),
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
  Widget _buildYouTubeSection() {
    final YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: 'cu_mXjAnTqg',
      params: YoutubePlayerParams(
        autoPlay: false,
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Wieso MUSST du den Personality Score ausfüllen?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              double playerWidth = constraints.maxWidth * 0.75;
              return Center(
                child: Container(
                  width: playerWidth,
                  child: YoutubePlayerIFrame(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                  ),
                ),
              );
            },
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
            handleTakeTest(context);
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

  Widget _buildYouTubeSection1() {
    final YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: 'fnSFCXFi69M',
      params: YoutubePlayerParams(
        autoPlay: false,
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Starte Hier",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              double playerWidth = constraints.maxWidth * 0.75; // 60% of the available width
              return Center(
                child: Container(
                  width: playerWidth,
                  child: YoutubePlayerIFrame(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                  ),
                ),
              );
            },
          ),
        ],
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
                      "PERSOENLICHKEITSSTUFEN",
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

// Widget for the tilted Adventurer Image with hover effect
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
        // No transformation for the container itself
        child: Transform(
          transform: !isHovered ? Matrix4.identity() : Matrix4.identity()
            ..setEntry(3, 2, 0.000) // For 3D perspective
            ..rotateY(pi / 1), // Tilt image to the right
          alignment: FractionalOffset.center, // Pivot at the center
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: !isHovered ? widget.screenWidth * 0.4 : widget.screenWidth * 0.5,
            height: !isHovered ? widget.screenHeight * 0.4 : widget.screenHeight * 0.5,
            child: Image.asset('assets/adventurer_front.png'),
          ),
        ),
      ),
    );
  }


}
