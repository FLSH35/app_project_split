import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/models/questionaire_model.dart';
import '../auth/auth_service.dart';
import '../models/question.dart';
import 'package:lottie/lottie.dart';
import 'custom_app_bar.dart';

class QuestionnaireDesktopLayout extends StatelessWidget {
  final ScrollController scrollController;

  QuestionnaireDesktopLayout({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Personality Score',
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xFFEDE8DB),
            ),
          ),
          Consumer2<AuthService, QuestionnaireModel>(
            builder: (context, authService, model, child) {
              if (authService.user == null) {
                Future.microtask(() {
                  Navigator.of(context).pushNamed('/signin');
                });
                return SizedBox.shrink();
              }

              if (model.questions.isEmpty) {
                model.loadQuestions('Kompetenz');
                model.loadProgress();
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

    return Column(
      children: [
        // Progress bar stays on top and does not scroll
        CustomProgressBar(totalSteps: totalSteps, currentStep: currentStep),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildQuestionsList(context, model),
                  _buildNavigationButtons(context, model),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildQuestionsList(BuildContext context, QuestionnaireModel model) {
    int start = model.currentPage * 7;
    int end = start + 7;
    List<Question> currentQuestions = model.questions.sublist(start, end > model.questions.length ? model.questions.length : end);

    return Column(
      children: currentQuestions.map((question) {
        int questionIndex = start + currentQuestions.indexOf(question);
        return Container(
          height: MediaQuery.of(context).size.height / 6, // Each question takes 1/6 of the screen height
          margin: EdgeInsets.only(bottom: 10.0), // Reduced bottom margin
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: MediaQuery.of(context).size.width / 8),
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
              // Description under the slider
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
                    model.answers[questionIndex]?.toString() ?? '0',
                    style: TextStyle(color: Colors.grey[900], fontSize: 16),
                  ),Text(
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


  Widget _buildNavigationButtons(BuildContext context, QuestionnaireModel model) {
    int end = (model.currentPage + 1) * 7;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (model.currentPage > 0)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              backgroundColor: Colors.black,
              side: BorderSide(color: Color(0xFFCB9935)),
              shape: RoundedRectangleBorder( // Create square corners
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
              ),
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
              shape: RoundedRectangleBorder( // Create square corners
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
              ),
            ),

            onPressed: () {
              model.nextPage(context);
              _scrollToFirstQuestion(context);
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
              shape: RoundedRectangleBorder( // Create square corners
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
              ),
            ),
            onPressed: () {
              model.completeFirstTest(context);
              _scrollToFirstQuestion(context);
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
              shape: RoundedRectangleBorder( // Create square corners
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
              ),
            ),
            onPressed: () {
              model.completeSecondTest(context);
              _scrollToFirstQuestion(context);
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
              shape: RoundedRectangleBorder( // Create square corners
                borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
              ),
            ),
            onPressed: () {
              model.completeFinalTest(context);
              _scrollToFirstQuestion(context);
            },
            child: Text(
              'Fertigstellen',
              style: TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 18),
            ),
          ),
      ],
    );
  }

  void _scrollToFirstQuestion(BuildContext context) {
    final double questionPosition = MediaQuery.of(context).size.height / 3;
    scrollController.animateTo(
      questionPosition,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _showRewardAnimation(BuildContext context, String animationAsset) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.transparent,
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 80.0),
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
                  backgroundColor: index < currentStep ? Color(0xFFCB9935) : Colors.grey,
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
