import 'package:flutter/material.dart';
import 'package:personality_score/screens/signin_dialog.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../models/questionaire_model.dart';
import 'questionnaire_desktop_layout.dart'; // Desktop layout
import 'mobile_sidebar.dart'; // Mobile sidebar
import '../auth/auth_service.dart';
import '../models/question.dart';

class QuestionnaireScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context),
      desktop: QuestionnaireDesktopLayout(
        scrollController: _scrollController,
      ), // Desktop layout
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context), // Add AppBar with a menu button
      endDrawer: MobileSidebar(), // Mobile sidebar for navigation
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xFFEDE8DB),
            ),
          ),
          
          // Inside your Consumer2 widget
          Consumer2<AuthService, QuestionnaireModel>(
            builder: (context, authService, model, child) {
              if (authService.user == null) {
                Future.microtask(() {
                   showSignInDialog(context); // Show the SignInDialog;
                });
                return SizedBox.shrink();
              }

              if (model.questions.isEmpty) {
                model.loadQuestions('Kompetenz');
                return Center(child: CircularProgressIndicator());
              }

              return _buildQuestionnaire(context, model);
            },
          ),

        ],
      ),
    );
  }
  void showSignInDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => SignInDialog(
        emailController: emailController,
        passwordController: passwordController,

        allowAnonymous: true,
      ),
    ).then((_) {
      // Dispose controllers when the dialog is closed
      emailController.dispose();
      passwordController.dispose();
    });
  }


  // Mobile AppBar with a menu button to open the sidebar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('FRAGEN'),
      backgroundColor: Color(0xFFF7F5EF), // Light grey for mobile
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu), // Menu icon to open the sidebar
            onPressed: () {
              Scaffold.of(context).openEndDrawer(); // Open the sidebar for mobile
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false, // Remove back button for mobile
    );
  }

  // Build the questionnaire for mobile layout
  Widget _buildQuestionnaire(BuildContext context, QuestionnaireModel model) {
    int totalSteps = (model.questions.length / 7).ceil(); // 3 questions per page
    int currentStep = model.currentPage;

    return Column(
      children: [
        // Progress bar stays on top and does not scroll
        CustomProgressBar(totalSteps: totalSteps, currentStep: currentStep),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                _buildQuestionsList(context, model),
                _buildNavigationButtons(context, model),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList(BuildContext context, QuestionnaireModel model) {
    int questionsPerPage = 7; // Only show 7 questions per page
    int start = model.currentPage * questionsPerPage;
    int end = start + questionsPerPage;

    // Ensure end does not go beyond the number of questions
    List<Question> currentQuestions = model.questions.sublist(
        start, end > model.questions.length ? model.questions.length : end);

    return Column(
      children: currentQuestions.map((question) {
        int questionIndex = start + currentQuestions.indexOf(question);
        return Container(
          margin: EdgeInsets.only(bottom: 40.0), // Margin between questions
          height: MediaQuery.of(context).size.height / 4,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        question.text,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Roboto',
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: null,
                      ),
                    ),
                  ),
                  if (question.backgroundInfo != "empty") ...[
                    SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: () {
                        _showInfoDialog(context, question.backgroundInfo);
                      },
                      child: Icon(
                        Icons.help_outline, // Question mark icon
                        color: Colors.grey[700],
                        size: 24.0,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8.0),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Row of vertical lines with margin to align with slider divisions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 12.0), // Adjust width to match desired margin
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(11, (index) {
                              return Container(
                                width: 1,
                                height: 20, // Height of the tick mark
                                color: Colors.grey, // Color of the tick mark
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
                    value: question.value < 0
                        ? 10 - (model.answers[questionIndex] ?? 0).toDouble()
                        : (model.answers[questionIndex] ?? 0).toDouble(),
                    onChanged: (val) {
                      model.answerQuestion(
                          questionIndex,
                          question.value < 0 ? 10 - val.toInt() : val.toInt());
                    },
                    min: 0,
                    max: 10,
                    divisions: 10, // Indicates 10 steps on the slider
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
                    style: TextStyle(color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SelectableText(
                    'EHER NEIN',
                    style: TextStyle(color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SelectableText(
                    'NEUTRAL',
                    style: TextStyle(color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SelectableText(
                    'EHER JA',
                    style: TextStyle(color: Colors.grey[900], fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SelectableText(
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

  void _showInfoDialog(BuildContext context, String backgroundInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Info"),
          content: Text(backgroundInfo),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }



  Widget _buildNavigationButtons(BuildContext context, QuestionnaireModel model) {
    int questionsPerPage = 7; // Adjusted for mobile layout
    int start = model.currentPage * questionsPerPage;
    int end = start + questionsPerPage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (model.currentPage > 0)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
              backgroundColor: Colors.black,
              side: BorderSide(color: Color(0xFFCB9935)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () => model.prevPage(),
            child: Text(
              'Zurück',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
            ),
          ),
        if (end < model.questions.length)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
              backgroundColor: Color(0xFFCB9935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              model.nextPage(context);
              _scrollToFirstQuestion(context);
            },
            child: Text(
              'Weiter',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
            ),
          ),
        if (end >= model.questions.length && !model.isFirstTestCompleted)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
              backgroundColor: Color(0xFFCB9935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              model.completeFirstTest(context);
              _scrollToFirstQuestion(context);
            },
            child: Text(
              'Fertigstellen',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
            ),
          ),
        if (end >= model.questions.length &&
            model.isFirstTestCompleted &&
            !model.isSecondTestCompleted)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
              backgroundColor: Color(0xFFCB9935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              model.completeSecondTest(context);
              _scrollToFirstQuestion(context);
            },
            child: Text(
              'Fertigstellen',
              style: TextStyle(
                  color: Colors.black, fontFamily: 'Roboto', fontSize: 18),
            ),
          ),
        if (end >= model.questions.length && model.isSecondTestCompleted)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
              backgroundColor: Color(0xFFCB9935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: () {
              model.completeFinalTest(context);
              _scrollToFirstQuestion(context);
            },
            child: Text(
              'Fertigstellen',
              style: TextStyle(
                  color: Colors.black, fontFamily: 'Roboto', fontSize: 18),
            ),
          ),
      ],
    );
  }

  void _scrollToFirstQuestion(BuildContext context) {
    _scrollController.animateTo(
      0.0,
      duration: Duration(seconds: 1),
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
          vertical: 20.0, horizontal: 16.0), // Adjusted padding for mobile
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 8,
                  color:
                  index <= currentStep ? Color(0xFFCB9935) : Colors.grey,
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
