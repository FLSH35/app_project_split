import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/models/questionaire_model.dart';
import '../auth/auth_service.dart';
import '../models/question.dart';
import 'package:lottie/lottie.dart';
import 'custom_app_bar.dart';

class QuestionnaireScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Personality Score',
      ),
      body: Stack(
        children: [
          // Background color
          Positioned.fill(
            child: Container(
              color: Color(0xFFEDE8DB),
            ),
          ),
          Consumer2<AuthService, QuestionnaireModel>(
            builder: (context, authService, model, child) {
              // If the user is not authenticated, navigate to the sign-in screen
              if (authService.user == null) {
                Future.microtask(() {
                  Navigator.of(context).pushNamed('/signin');
                });
                return SizedBox.shrink(); // Return an empty widget while redirecting
              }

              if (model.questions.isEmpty) {
                model.loadQuestions('Kompetenz');
                model.loadProgress(); // Load user progress
                return Center(child: CircularProgressIndicator());
              }

              return _buildQuestionnaire(context, model);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaire(BuildContext context, QuestionnaireModel model) {
    int totalSteps = (model.questions.length / 7).ceil();
    int currentStep = model.currentPage;
    int answeredQuestions = model.answers.where((answer) => answer != null).length;
    int totalQuestions = model.questions.length;

    int start = model.currentPage * 7;
    int end = start + 7;
    List<Question> currentQuestions = model.questions.sublist(start, end > model.questions.length ? model.questions.length : end);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80.0), // Increased margin
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            // Test description taking up half of the screen height
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Test Description',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This test will help us understand your personality better. Please answer the questions honestly and thoughtfully.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: null, // Allow multiple lines
                    softWrap: true,  // Wrap text automatically
                  ),
                ],
              ),
            ),
            // Progress bar and question list
            CustomProgressBar(totalSteps: totalSteps, currentStep: currentStep),
            SizedBox(height: 20),
            Column(
              children: currentQuestions.map((question) {
                int questionIndex = start + currentQuestions.indexOf(question);
                return Container(
                  height: MediaQuery.of(context).size.height / 6, // Each question takes 1/6 of the screen height
                  margin: EdgeInsets.only(bottom: 10.0), // Reduced bottom margin
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: MediaQuery.of(context).size.width / 8), // Adjusted vertical padding
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          question.text,
                          style: TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 22),
                          textAlign: TextAlign.center,
                          maxLines: 3, // Limit to a maximum of 3 lines
                          overflow: TextOverflow.ellipsis, // Show ellipsis if the text is too long
                        ),
                      ),
                      SizedBox(height: 8.0), // Reduced height
                      Slider(
                        value: (model.answers[questionIndex] ?? 0).toDouble(),
                        onChanged: (val) {
                          model.answerQuestion(questionIndex, val.toInt());
                        },
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: model.answers[questionIndex]?.toString() ?? '0',
                        activeColor: Color(0xFFCB9935),
                        inactiveColor: Colors.grey,
                        thumbColor: Color(0xFFCB9935),
                      ),
                      SizedBox(height: 4), // Reduced height
                      Text(
                        model.answers[questionIndex]?.toString() ?? '0',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (model.currentPage > 0)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      backgroundColor: Colors.black,
                      side: BorderSide(color: Color(0xFFCB9935)),
                    ),
                    onPressed: () => model.prevPage(),
                    child: Text(
                      'Zurück',
                      style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
                    ),
                  ),
                if (end < model.questions.length)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      backgroundColor: Color(0xFFCB9935),
                    ),
                    onPressed: () {
                      model.nextPage(context);
                      _scrollToFirstQuestion(context); // Scroll up to the first question
                    },
                    child: Text(
                      'Weiter',
                      style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
                    ),
                  ),
                if (end >= model.questions.length && !model.isFirstTestCompleted)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      backgroundColor: Color(0xFFCB9935),
                    ),
                    onPressed: () {
                      model.completeFirstTest(context);
                      _scrollToFirstQuestion(context); // Scroll up to the first question
                    },
                    child: Text(
                      'Fertigstellen',
                      style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
                    ),
                  ),
                if (end >= model.questions.length && model.isFirstTestCompleted && !model.isSecondTestCompleted)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      backgroundColor: Color(0xFFCB9935),
                    ),
                    onPressed: () {
                      model.completeSecondTest(context);
                      _scrollToFirstQuestion(context); // Scroll up to the first question
                      _showRewardAnimation(context, 'stars.json'); // Show reward animation
                    },
                    child: Text(
                      'Fertigstellen',
                      style: TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 18),
                    ),
                  ),
                if (end >= model.questions.length && model.isSecondTestCompleted)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      backgroundColor: Color(0xFFCB9935),
                    ),
                    onPressed: () {
                      model.completeFinalTest(context);
                      _scrollToFirstQuestion(context); // Scroll up to the first question
                    },
                    child: Text(
                      'Fertigstellen',
                      style: TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 18),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _scrollToFirstQuestion(BuildContext context) {
    final double questionPosition = MediaQuery.of(context).size.height / 3;
    _scrollController.animateTo(
      questionPosition,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _showRewardAnimation(BuildContext context, String animationAsset) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close the transparent overlay after 2 seconds
        });

        return Stack(
          alignment: Alignment.center,
          children: [
            // Transparent overlay
            Container(
              color: Colors.transparent, // Transparent color
            ),
            // Reward animation
            Lottie.asset(
              'assets/$animationAsset',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ],
        );
      },
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
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 80.0), // Increased margin
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 8, // Increased height of the progress bar
                  color: index <= currentStep ? Color(0xFFCB9935) : Colors.grey,
                ),
                CircleAvatar(
                  radius: 12, // Increased size of the progress indicator
                  backgroundColor: index < currentStep ? Color(0xFFCB9935) : Colors.grey,
                  child: index < currentStep
                      ? Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 18, // Increased icon size
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
