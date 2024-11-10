// questionnaire_desktop_tutorial_layout.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/models/questionaire_model.dart'; // Make sure to import your QuestionnaireModel
import 'custom_app_bar.dart';

class QuestionnaireDesktopTutorialLayout extends StatefulWidget {
  final ScrollController scrollController;

  QuestionnaireDesktopTutorialLayout({required this.scrollController});

  @override
  _QuestionnaireDesktopTutorialLayoutState createState() =>
      _QuestionnaireDesktopTutorialLayoutState();
}

class _QuestionnaireDesktopTutorialLayoutState
    extends State<QuestionnaireDesktopTutorialLayout> {
  bool isLoading = true;
  List<String> tutorialQuestions = [
    'Mit dem Schieberegler kannst ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich ohne lange Nachzudenken.',
    'Ich antworte ehrlich und gewissenhaft.',
  ];
  Map<int, int> answers = {};
  int currentPage = 0;
  int questionsPerPage = 7;

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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Personality Score',
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xFFEDE8DB),
            ),
          ),
          _buildQuestionnaire(context),
        ],
      ),
    );
  }

  Widget _buildQuestionnaire(BuildContext context) {
    int totalSteps = (tutorialQuestions.length / questionsPerPage).ceil();
    int currentStep = currentPage;

    return Column(
      children: [
        // Progress bar stays on top and does not scroll
        CustomProgressBar(totalSteps: totalSteps, currentStep: currentStep),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  _buildYouTubeSection(),
                  SizedBox(height: 40),
                  _buildQuestionsList(context),
                  SizedBox(height: 40),
                  _buildNavigationButton(context),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYouTubeSection() {
    final YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: 'fnSFCXFi69M', // Replace with your YouTube video ID
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
          SelectableText(
            "Tutorial Video",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              double playerWidth = constraints.maxWidth * 0.75; // 75% of available width
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
        end > tutorialQuestions.length ? tutorialQuestions.length : end);

    return Column(
      children: currentQuestions.map((questionText) {
        int questionIndex = start + currentQuestions.indexOf(questionText);
        return Container(
          height: MediaQuery.of(context).size.height / 4,
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.symmetric(
              vertical: 10.0, horizontal: MediaQuery.of(context).size.width / 5),
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
                  style:
                  TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 22),
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
                      // Left margin
                      SizedBox(width: 12.0),
                      // Tick marks row
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
                      // Right margin
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
                        color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SelectableText(
                    'EHER NEIN',
                    style: TextStyle(
                        color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SelectableText(
                    'NEUTRAL',
                    style: TextStyle(
                        color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SelectableText(
                    'EHER JA',
                    style: TextStyle(
                        color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SelectableText(
                    'JA',
                    style: TextStyle(
                        color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
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
    int totalPages = (tutorialQuestions.length / questionsPerPage).ceil();
    int start = currentPage * questionsPerPage;
    int end = start + questionsPerPage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous page button
        if (currentPage > 0)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
              backgroundColor: Colors.black,
              side: BorderSide(color: Color(0xFFCB9935)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              setState(() {
                currentPage--;
                _scrollToFirstQuestion();
              });
            },
            child: Text(
              'Zurück',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
            ),
          ),

        // Next page or "Beginne den Test" button
        if (end < tutorialQuestions.length)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
              backgroundColor: Color(0xFFCB9935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              setState(() {
                currentPage++;
                _scrollToFirstQuestion();
              });
            },
            child: Text(
              'Weiter',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
            ),
          ),
        if (end >= tutorialQuestions.length)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
              backgroundColor: Color(0xFFCB9935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/questionnaire');
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

  void _scrollToFirstQuestion() {
    widget.scrollController.animateTo(
      0.0, // Scroll to the very top
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  CustomProgressBar({required this.totalSteps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 20.0, horizontal: 80.0),
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 8,
                  color: index <= currentStep ? Color(0xFFCB9935) : Colors.grey,
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                  index < currentStep ? Color(0xFFCB9935) : Colors.grey,
                  child: index < currentStep
                      ? Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 18,
                  )
                      : Container(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
