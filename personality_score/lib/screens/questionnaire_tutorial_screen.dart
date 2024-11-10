import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'questionnaire_desktop_tutorial_layout.dart'; // Updated Desktop Tutorial Layout

import 'mobile_sidebar.dart'; // Mobile sidebar
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class QuestionnaireTutorialScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  final List<String> tutorialQuestions = [
    'Mit dem Schieberegler kannst ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich ohne lange Nachzudenken.',
    'Ich antworte ehrlich und gewissenhaft. ',
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context),
      desktop: QuestionnaireDesktopTutorialLayout(
        scrollController: _scrollController,
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      endDrawer: MobileSidebar(),
      body: Stack(
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('TUTORIAL'),
      backgroundColor: Color(0xFFF7F5EF),
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
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildQuestionnaire(BuildContext context) {
    return Column(
      children: [
        _buildYouTubeSection(), // Add YouTube video at the top
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                _buildQuestionsList(context),
                _buildNavigationButton(context),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList(BuildContext context) {
    return Column(
      children: tutorialQuestions.map((questionText) {
        return Container(
          margin: EdgeInsets.only(bottom: 40.0),
          height: MediaQuery.of(context).size.height / 4,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    questionText,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              _buildSlider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NEIN',
                    style: TextStyle(color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  Text(
                    'EHER NEIN',
                    style: TextStyle(color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  Text(
                    'NEUTRAL',
                    style: TextStyle(color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  Text(
                    'EHER JA',
                    style: TextStyle(color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  Text(
                    'JA',
                    style: TextStyle(color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlider() {
    double sliderValue = 5; // Initial value for the slider

    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Row of vertical lines behind the slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 12.0), // Left margin
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(11, (index) {
                        return Container(
                          width: 1,
                          height: 20, // Height of the tick mark
                          color: Colors.grey, // Tick mark color
                        );
                      }),
                    ),
                  ),
                ),
                SizedBox(width: 12.0), // Right margin
              ],
            ),
            // The slider itself
            Slider(
              value: sliderValue,
              onChanged: (newValue) {
                setState(() {
                  sliderValue = newValue;
                });
              },
              min: 0,
              max: 10,
              divisions: 10, // 10 steps on the slider
              activeColor: Color(0xFFCB9935),
              inactiveColor: Colors.grey,
              thumbColor: Color(0xFFCB9935),
            ),
          ],
        );
      },
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
        Navigator.of(context).pushNamed('/questionnaire');
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
}
