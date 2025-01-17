// questionnaire_screen.dart

import 'package:flutter/material.dart';
import 'package:personality_score/screens/signin_dialog.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../models/questionaire_model.dart';
import 'questionnaire_desktop_layout.dart'; // Desktop Layout
import 'home_screen/mobile_sidebar.dart';              // Mobile Sidebar
import '../auth/auth_service.dart';
import '../models/question.dart';

class QuestionnaireScreen extends StatefulWidget {
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Zeigt an, ob gerade geladen wird (z.B. Fragen werden geholt) oder
  /// wichtige Aktionen (z.B. Login) im Gange sind.
  bool isLoading = true;

  /// Gibt an, ob ein:e User:in überhaupt eingeloggt ist.
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();

    // Nach dem ersten Frame prüfen, ob ein User eingeloggt ist;
    // ggf. SignIn-Dialog anzeigen und Fragen laden.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Ist noch niemand eingeloggt?
      if (authService.user == null) {
        // Sign-In-Dialog anzeigen


        await authService.signInAnonymously();

        // Prüfen, ob sich jemand eingeloggt hat; wenn nein, Seite schließen:
        if (authService.user == null) {
          Navigator.of(context).pop();
          return; // Abbrechen
        }
      }

      // Falls wir hier ankommen, ist jemand eingeloggt:
      setState(() {
        _isAuthenticated = true;
        isLoading = true; // Startet das Laden der Fragen
      });

      // Fragen laden
      await _loadQuestions();
    });
  }
  /// Lädt die Fragen (z.B. aus Firestore).
  Future<void> _loadQuestions() async {
    final model = Provider.of<QuestionnaireModel>(context, listen: false);

    try {
      if (model.questions.isEmpty) {
        // Nur laden, wenn noch keine Fragen im Modell vorhanden sind
        await model.loadQuestions('Kompetenz');
      }
    } catch (e) {
      // Fehlermeldung anzeigen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Fragen: $e'),
          ),
        );
      }
    } finally {
      // Wir sind fertig (Erfolg oder Fehler), daher Ladezustand beenden
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    // Layout für Mobile vs. Desktop
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context),
      desktop: QuestionnaireDesktopLayout(
        scrollController: _scrollController,
      ),
    );
  }

  /// Erzeugt das Layout für Mobile
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      endDrawer: MobileSidebar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Color(0xFFEDE8DB)),
          ),
          // Nachdem Auth + Fragen geladen wurden, zeigen wir den Fragebogen an
          Consumer<QuestionnaireModel>(
            builder: (context, model, child) {
              return _buildQuestionnaire(context, model);
            },
          ),
        ],
      ),
    );
  }

  /// AppBar mit Menü-Button für Mobile
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

  /// Baut den eigentlichen Fragebogen-Body für Mobile
  Widget _buildQuestionnaire(BuildContext context, QuestionnaireModel model) {
    int totalSteps = (model.questions.length / 7).ceil();
    int currentStep = model.currentPage;

    return Column(
      children: [
        // Fortschrittsbalken oben
        CustomProgressBar(totalSteps: totalSteps, currentStep: currentStep),
        // Scrollbarer Bereich mit den Fragen + Buttons
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                _buildQuestionsList(context, model),
                SizedBox(height: 10),
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
    int questionsPerPage = 7;
    int start = model.currentPage * questionsPerPage;
    int end = start + questionsPerPage;

    // Unterliste der Fragen für die aktuelle Seite
    List<Question> currentQuestions = model.questions.sublist(
      start,
      end > model.questions.length ? model.questions.length : end,
    );

    return Column(
      children: currentQuestions.map((question) {
        int questionIndex = start + currentQuestions.indexOf(question);

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
              // Frage-Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 6, // Begrenzte Höhe
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          question.text,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: null, // Unbegrenzte Anzahl an Zeilen
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.0),

              // Slider (mit Ticks im Hintergrund)
              Stack(
                alignment: Alignment.center,
                children: [
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
                  Slider(
                    value: question.value < 0
                        ? 10 - (model.answers[questionIndex] ?? 0).toDouble()
                        : (model.answers[questionIndex] ?? 0).toDouble(),
                    onChanged: (val) {
                      model.answerQuestion(
                        questionIndex,
                        question.value < 0 ? 10 - val.toInt() : val.toInt(),
                      );
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

              // Skalen-Beschriftung
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

  void _showInfoDialog(BuildContext context, String backgroundInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Info"),
          content: Text(backgroundInfo),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  /// Buttons zum Navigieren zwischen den Seiten + Test-Abschluss
  Widget _buildNavigationButtons(BuildContext context, QuestionnaireModel model) {
    int questionsPerPage = 7;
    int start = model.currentPage * questionsPerPage;
    int end = start + questionsPerPage;

    bool showCompleteButton = false;
    String completeButtonAction = '';
    String completeButtonLabel = 'Fertigstellen';
    bool isBlackButton = false;

    // Wenn wir am Ende angelangt sind, soll ggf. "Fertigstellen" angezeigt werden
    if (end >= model.questions.length) {
      if (!model.isFirstTestCompleted) {
        showCompleteButton = true;
        completeButtonAction = 'first';
      } else if (!model.isSecondTestCompleted) {
        showCompleteButton = true;
        completeButtonAction = 'second';
      } else if (model.isSecondTestCompleted) {
        showCompleteButton = true;
        completeButtonAction = 'final';
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Zurück-Button
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
                color: Colors.white,
                fontFamily: 'Roboto',
                fontSize: 18,
              ),
            ),
          ),

        // Weiter-Button (sofern noch nicht letzte Seite)
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
              _scrollToFirstQuestion();
            },
            child: Text(
              'Weiter',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
                fontSize: 18,
              ),
            ),
          ),

        // Fertigstellen-Button (wenn letzter Fragenblock)
        if (showCompleteButton)
          isLoading
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
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
              backgroundColor: isBlackButton ? Colors.black : Color(0xFFCB9935),
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

              try {
                if (completeButtonAction == 'first') {
                  await model.completeFirstTest(context);
                } else if (completeButtonAction == 'second') {
                  await model.completeSecondTest(context);
                } else if (completeButtonAction == 'final') {
                  await model.completeFinalTest(context);
                }
                _scrollToFirstQuestion();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ein Fehler ist aufgetreten: $e'),
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              }
            },
            child: Text(
              completeButtonLabel,
              style: TextStyle(
                color: isBlackButton ? Colors.white : Colors.black,
                fontFamily: 'Roboto',
                fontSize: 18,
              ),
            ),
          ),
      ],
    );
  }

  /// Scrollt wieder nach oben
  void _scrollToFirstQuestion() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

/// Fortschrittsbalken für die Seiten
class CustomProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  CustomProgressBar({required this.totalSteps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Für Mobile Layout etwas engeres Padding
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
