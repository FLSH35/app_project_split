import 'package:flutter/material.dart';
import 'package:personality_score/screens/signin_dialog.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/models/questionaire_model.dart';
import '../auth/auth_service.dart';
import '../models/question.dart';
import 'custom_app_bar.dart';

class QuestionnaireDesktopLayout extends StatefulWidget {
  final ScrollController scrollController;

  QuestionnaireDesktopLayout({required this.scrollController});

  @override
  _QuestionnaireDesktopLayoutState createState() => _QuestionnaireDesktopLayoutState();
}

class _QuestionnaireDesktopLayoutState extends State<QuestionnaireDesktopLayout> {
  bool isLoading = true;
  bool _isAuthenticated = false; // Track authentication status

  @override
  void initState() {
    super.initState();

    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (authService.user == null) {
        // Show the sign-in dialog
        await showSignInDialog(context);

        // After the dialog is closed, check if the user is authenticated
        if (authService.user != null) {
          setState(() {
            _isAuthenticated = true;
          });
          // Load questions after authentication
          _loadQuestions();
        } else {
          // User did not sign in; you can handle this case as needed
          // For example, navigate back or show a message
          Navigator.of(context).pop(); // Close the questionnaire screen
        }
      } else {
        // User is already authenticated
        setState(() {
          _isAuthenticated = true;
        });
        _loadQuestions();
      }
    });
  }
  Future<void> showSignInDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => SignInDialog(
        emailController: TextEditingController(),
        passwordController: TextEditingController(),
        allowAnonymous: true, // Or as per your requirement
      ),
    );
  }
  Future<void> _loadQuestions() async {
    final model = Provider.of<QuestionnaireModel>(context, listen: false);

    if (model.questions.isEmpty) {
      await model.loadQuestions('Kompetenz');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If not authenticated, show a loading indicator or placeholder
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Personality Score',
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          Consumer<QuestionnaireModel>(
            builder: (context, model, child) {
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
            controller: widget.scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
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
        ),
      ],
    );
  }

  Widget _buildQuestionsList(BuildContext context, QuestionnaireModel model) {
    int start = model.currentPage * 7;
    int end = start + 7;
    List<Question> currentQuestions = model.questions.sublist(
        start, end > model.questions.length ? model.questions.length : end);

    return Column(
      children: currentQuestions.map((question) {
        int questionIndex = start + currentQuestions.indexOf(question);
        return Container(
          height: MediaQuery.of(context).size.height / 4, // Each question takes 1/4 of the screen height
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SelectableText(
                      question.text,
                      style: TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 22),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  if(question.backgroundInfo != "empty" && false) Tooltip(
                        message: question.backgroundInfo, // Add background info to the Question model
                        padding: EdgeInsets.all(8.0),
                        textStyle: TextStyle(color: Colors.white, fontSize: 14),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      child: Icon(
                        Icons.help_outline, // Use a question mark icon
                        color: Colors.grey[700],
                        size: 24.0,
                      ),
                      ),
                ],
              ),
              SizedBox(height: 8.0),
              // Existing slider and options implementation...
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 12.0), // Adjust width to match desired margin
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 12.0), // Adjust for desired spacing
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
                      SizedBox(width: 12.0), // Adjust width to match desired margin
                    ],
                  ),
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


  Widget _buildNavigationButtons(BuildContext context, QuestionnaireModel model) {
    int questionsPerPage = 7; // Number of questions per page
    int start = model.currentPage * questionsPerPage;
    int end = start + questionsPerPage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous page button
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

        // Next page button
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

        // "Fertigstellen" button for the first test
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

        // "Fertigstellen" button for the second test
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

        // Final "Fertigstellen" button for the last test
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
                  color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
            ),
          ),
      ],
    );
  }

  void _scrollToFirstQuestion(BuildContext context) {
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
