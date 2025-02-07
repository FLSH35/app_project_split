import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:personality_score/services/question_service.dart';
import 'package:personality_score/models/question.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../helper_functions/endpoints.dart';
import '../screens/signin_dialog.dart';

class QuestionnaireModel with ChangeNotifier {
  QuestionService _questionService = QuestionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isSubscribing = false;
  bool _isShowingResults = false;

  int score_factor = 0;

  bool isSubscribed = false;

  int _totalScore = 0; // Store total score across all sets

  int combinedTotalScore = 0;

  int _currentPage = 0;
  List<int?> _answers = [];
  String? _personalityType;
  int _progress = 0;
  bool _isFirstTestCompleted = false;
  bool _isSecondTestCompleted = false;
  String _currentSet = 'Kompetenz';

  bool _isLoading = false; // Track the loading state

  String? _finalCharacter;
  String? _finalCharacterDescription;

  set questionService(QuestionService service) {
    _questionService = service;
  }

  List<Question> get questions => _questions;

  bool get isLoading => _isLoading; // Expose loading state to the UI


  int get currentQuestionIndex => _currentQuestionIndex;


  int get totalScore => _totalScore;

  int get currentPage => _currentPage;

  List<int?> get answers => _answers;

  String? get personalityType => _personalityType;

  int get progress => _progress;

  bool get isFirstTestCompleted => _isFirstTestCompleted;

  bool get isSecondTestCompleted => _isSecondTestCompleted;

  String? get finalCharacter => _finalCharacter;

  String? get finalCharacterDescription => _finalCharacterDescription;

  TextEditingController nameController = TextEditingController();

  String? highestResultCollection = null;




  Future<void> saveProgress() async {
    _isLoading = true;
    notifyListeners();

    User? user = _auth.currentUser;
    if (user != null) {
      try {

        if (highestResultCollection == null) {
          throw Exception("No results collection found for the user.");
        }

        // Create a list of maps with question IDs and corresponding scores
        List<Map<String, dynamic>> answersWithIds = _questions.asMap().entries.map((entry) {
          int index = entry.key;
          Question question = entry.value;
          return {
            'id': question.id,
            'answer': _answers[index],
          };
        }).toList();

        // Save progress to the highest results collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(highestResultCollection!)
            .doc(_currentSet)
            .set({
          'set': _currentSet,
          'totalScore': _totalScore,
          'isCompleted': _isFirstTestCompleted || _isSecondTestCompleted,
          'completionDate': FieldValue.serverTimestamp(),
          'currentPage': _currentPage,
          'answers': answersWithIds, // Save answers with IDs
          'combinedTotalScore': combinedTotalScore,
        }, SetOptions(merge: true));

        print("Progress saved to $highestResultCollection");
      } catch (error) {
        print("Error saving progress: $error");
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }



  Future<void> loadProgress() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Get the highest result collection
        highestResultCollection = await getHighestResultCollection(user.uid);

        if (highestResultCollection != null) {
          // Fetch the data from the highest result collection
          DocumentSnapshot resultSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(highestResultCollection!)
              .doc(_currentSet)
              .get();

          if (resultSnapshot.exists) {
            final data = resultSnapshot.data() as Map<String, dynamic>;
            _totalScore = data['totalScore'] ?? 0;
            _isFirstTestCompleted = data['isCompleted'] ?? false;
            _currentPage = data['currentPage'] ?? 0;

            // Parse answers with IDs
            _answers = List<int?>.from(
              _questions.map((q) {
                var savedAnswer = data['answers']?.firstWhere(
                        (a) => a['id'] == q.id,
                    orElse: () => null);
                return savedAnswer?['answer'] ?? 5; // Default to 5 if no saved answer
              }),
            );

            _finalCharacter = data['finalCharacter'];
            _finalCharacterDescription = data['finalCharacterDescription'];
            combinedTotalScore = data['combinedTotalScore'] ?? 0;

            notifyListeners();
          } else {
            print("No data found in the highest result collection.");
          }
        } else {
          print("No result collections found for the user.");
        }
      } catch (error) {
        print("Error loading progress: $error");
      }
    }
  }



  /// Loading questions from the service
  Future<void> loadQuestions(String set) async {
    User? user = _auth.currentUser;
    _isLoading = true; // Set loading to true while fetching data
    notifyListeners(); // Notify listeners to update the UI

    _currentSet = set;

    // Get the highest result collection
    highestResultCollection = await getHighestResultCollection(user!.uid);
    try {
      // Load questions from the service
      List<Question> loadedQuestions = await _questionService.fetchFilteredQuestions(
          set);

      // Create a Set to store unique questions
      Set<String> uniqueQuestionTexts = {};
      List<Question> uniqueQuestions = [];

      for (var question in loadedQuestions) {
        if (uniqueQuestionTexts.add(
            question.text)) { // Ensure uniqueness by question text
          uniqueQuestions.add(question);
        }
      }

      // Set loaded questions and reset answers
      _questions = uniqueQuestions;
      _answers = List<int?>.filled(_questions.length, 5);
    } catch (error) {
      print("Error loading questions: $error");
    } finally {
      _isLoading = false; // Set loading to false after fetching data
      notifyListeners(); // Notify listeners to update the UI
    }
  }


  void answerQuestion(int index, int value) {
    // Ensure the answers list stores a map of ID and value
    _answers[index] = value;

    // Update the total score
    _totalScore = _answers.where((a) => a != null).fold(0, (sum, a) => sum + a!);

    // Save progress with IDs included
    saveProgress();
    notifyListeners();
  }


  Future<void> nextPage(BuildContext context) async {
    if ((_currentPage + 1) * 7 < _questions.length) {
      _currentPage++;
      await saveProgress(); // Ensure saving is completed before proceeding
      notifyListeners();
    }
  }


  void continueFromLastPage() {
    // This function just notifies listeners since the currentPage is already loaded
    notifyListeners();
  }


  Future<void> prevPage() async {
    if (_currentPage > 0) {
      _currentPage--;
      await saveProgress(); // Ensure saving is completed before proceeding
      notifyListeners();
    }
  }

  void reset() {
    _totalScore = 0;
    _currentQuestionIndex = 0;
    _currentPage = 0;
    _progress = 0;
    _answers = List<int?>.filled(_questions.length, 5);
    _personalityType = null;
    _isFirstTestCompleted = false;
    _isSecondTestCompleted = false;
    combinedTotalScore = 0;
    loadQuestions('Kompetenz');
    saveProgress();
    notifyListeners();
  }



  double getProgress() {
    if (_questions.isEmpty) return 0.0;
    return (_currentPage + 1) / (_questions.length / 7).ceil();
  }

  Future<void> setPersonalityType(String type) async {
    _personalityType = type;
    await saveProgress();
    notifyListeners();
  }

  Future<void> completeFirstTest(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Await the export operation if it's asynchronous
    await exportUserAnswers(user.uid, highestResultCollection!, _questions, _answers);

    _totalScore = _answers.where((a) => a != null).fold(0, (sum, a) => sum + a!);

    String message;
    List<String> teamCharacters;
    String nextSet;

    int possibleScore = _questions.length * 10; // Calculate possible score for the current set

    if (_totalScore > 275) {
      message = """Herzlichen Glückwunsch: Du hast den ersten Teil des Tests absolviert. 
Damit scheiden 4 von 8 möglichen Persönlichkeitsstufen für dich aus. Deinen Antworten zufolge befindest du dich zwischen Stufe 5 und Stufe 8. Damit hast du bereits echte „Lebenskompetenz“ erreicht und gehörst damit bereits zu einer kleinen Minderheit. Wir gehen davon aus, dass über 90% der Menschen auf den Stufen 1 bis 4 im Bereich der „Inkompetenz“ zu verorten sind. Für deine bisherige Entwicklung also schonmal ein dickes Lob.
Im nächsten Fragensegment engen wir dein Ergebnis noch weiter ein. Viel Spaß!
""";
      teamCharacters = [
        "LifeArtist.webp",
        "Individual.webp",
        "Adventurer.webp",
        "Traveller.webp"
      ];
      nextSet = 'BewussteKompetenz';
    } else {
      message = """Herzlichen Glückwunsch: Du hast den ersten Teil des Tests absolviert. 
Damit scheiden 4 von 8 möglichen Persönlichkeitsstufen für dich aus. Deinen Antworten zufolge befindest du dich zwischen Stufe 1 und Stufe 4. Noch hast du wahre „Lebenskompetenz“ (diese beginnt ab Stufe 5) nicht erreicht, sondern befindest dich auf dem Weg dahin. Das ist aber überhaupt nicht schlimm, sondern völlig normal. Wir gehen davon aus, dass über 90% der Menschen auf den Stufen 1 bis 4 zu verorten sind.
Im nächsten Fragensegment engen wir dein Ergebnis noch weiter ein. Viel Spaß!
""";

      teamCharacters = ["Resident.webp", "Explorer.webp", "Reacher.webp", "Anonymous.webp"];
      nextSet = 'BewussteInkompetenz';
    }

    // Controller für die E-Mail-Eingabe und den Vornamen
    TextEditingController emailController = TextEditingController();
    TextEditingController nameController = TextEditingController();

    // Variablen für den Newsletter/Ergebnisablauf
    bool isSubscribed = false;
    bool showResults = false;
    bool _isSubscribing = false;
    bool _isShowingResults = false;

    // Falls ein displayName vorhanden ist, direkt Ergebnis anzeigen (keine E-Mail-Abfrage nötig)
    bool userHasDisplayName = user.displayName != null;
    if (userHasDisplayName) {
      isSubscribed = true;
      showResults = true;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFC7C7C7), // Soft background
              title: const Text(
                'PersonalityScore-Ergebnis',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1) Wenn displayName nicht vorhanden und noch nicht abonniert: Newsletter anbieten
                    if (!userHasDisplayName && !isSubscribed) ...[
                      const SelectableText(
                        "Um dein Ergebnis zu sehen, abonniere unseren Newsletter.",
                        style: TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Dein Vorname',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-Mail-Adresse',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCB9935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _isSubscribing
                            ? null
                            : () async {
                          setState(() {
                            _isSubscribing = true;
                          });
                          if (emailController.text.isNotEmpty &&
                              nameController.text.isNotEmpty) {
                            try {
                              // Abonnieren
                              await subscribeToNewsletter_competenceScore(
                                emailController.text,
                                user.uid,
                                _totalScore,
                                nameController.text,
                              );

                              bool isEmailVerified = await isVerified(emailController.text);
                              if (isEmailVerified) {
                                setState(() {
                                  isSubscribed = true;
                                  showResults = true;
                                  _isSubscribing = false;
                                });
                              } else {
                                setState(() {
                                  isSubscribed = true;
                                  _isSubscribing = false;
                                });
                                // Erfolgsmeldung anzeigen
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('E-Mail-Bestätigung erforderlich'),
                                      content: Text(
                                        'Wir haben dir eine Bestätigungsmail an ${emailController.text} geschickt. Bitte überprüfe dein Postfach und bestätige deine E-Mail-Adresse, um dein Ergebnis zu erhalten.',
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Okay'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } catch (e) {
                              print('Ein Fehler ist aufgetreten: $e');
                              setState(() {
                                _isSubscribing = false;
                              });
                              showErrorMessage(
                                context,
                                'Ein Fehler ist aufgetreten. Bitte überprüfe deine Internetverbindung und versuche es erneut.',
                              );
                            }
                          } else {
                            setState(() {
                              _isSubscribing = false;
                            });
                            showErrorMessage(
                              context,
                              'Bitte gib eine gültige E-Mail-Adresse und deinen Vornamen ein.',
                            );
                          }
                        },
                        child: _isSubscribing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Newsletter abonnieren'),
                      ),
                      const SelectableText(
                        'Mit dem Abonnieren unseres Newsletters stimmst du zu, dass wir deine E-Mail-Adresse für zukünftige Mitteilungen verwenden dürfen. Du kannst dich jederzeit abmelden. Dein Vorname wird nur verwendet, um die Kommunikation persönlicher zu gestalten.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ]
                    // 2) Wenn schon abonniert, aber Ergebnis noch nicht angezeigt: Prüfung auf E-Mail-Bestätigung
                    else if (!showResults) ...[
                      const SelectableText(
                        'Klicke auf "Ergebnis anzeigen", um deine Punktzahl und den dazugehörigen Kommentar zu sehen. Du musst deine E-Mail-Adresse bestätigt haben, bevor du dein Ergebnis sehen kannst. Dies ist ein Sicherheits- und Qualitätsschritt.',
                        style: TextStyle(color: Colors.black54, fontSize: 12, fontFamily: 'Roboto'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCB9935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _isShowingResults
                            ? null
                            : () async {
                          setState(() {
                            _isShowingResults = true;
                          });
                          bool isEmailVerified = userHasDisplayName
                              ? true // Falls es einen displayName gibt, ist das automatisch "okay"
                              : await isVerified(emailController.text);

                          if (isEmailVerified) {
                            setState(() {
                              showResults = true;
                              _isShowingResults = false;
                            });
                          } else {
                            setState(() {
                              _isShowingResults = false;
                            });
                            showErrorMessage(
                              context,
                              'Bitte bestätige deine E-Mail-Adresse, um dein Ergebnis zu sehen.',
                            );
                          }
                        },
                        child: _isShowingResults
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Ergebnis anzeigen'),
                      ),
                    ]
                    // 3) Ergebnis-Bereich
                    else ...[
                        SelectableText(
                          '$_totalScore von $possibleScore Punkte erreicht',
                          style: const TextStyle(
                              color: Colors.black, fontFamily: 'Roboto', fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          message +
                              '\n\n Thomas A. Edison: "Viele Menschen, die im Leben scheitern, sind Menschen, die nicht erkennen, wie nah sie am Erfolg waren, als sie aufgaben."\n',
                          style: const TextStyle(
                              color: Colors.black, fontFamily: 'Roboto', fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          alignment: WrapAlignment.center,
                          children: teamCharacters
                              .map((character) => Image.asset(
                            'assets/$character',
                            width: 100,
                            height: 100,
                          ))
                              .toList(),
                        ),
                      ],
                  ],
                ),
              ),
              actions: [
                if (showResults) ...[
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFCB9935),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      loadQuestions(nextSet);
                      _isFirstTestCompleted = true;
                      _currentPage = 0;
                      _answers = List<int?>.filled(_questions.length, 5);
                      notifyListeners();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Weiter',
                      style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }



  Future<void> completeSecondTest(BuildContext context) async {
    User? user = _auth.currentUser;
    exportUserAnswers(user!.uid, highestResultCollection!, _questions, _answers);

    score_factor += _questions.length;
    _totalScore = _answers.where((a) => a != null).fold(0, (sum, a) => sum + a!);
    String message;
    List<String> teamCharacters;
    String nextSet;

    double threshold = (_questions.first.set == 'BewussteKompetenz') ? 675 : 540;
    final firstScore = await fetchScoreAndCount('Kompetenz');

    int progressScore = _totalScore + firstScore['score']!;

    if ( progressScore > threshold) { // Check if total score exceeds the threshold
      if (_questions.first.set == 'BewussteKompetenz') {
        message = """Herzlichen Glückwunsch: Du hast den zweiten Teil des Tests absolviert. Damit scheiden weitere 2 der möglichen Persönlichkeitsstufen für dich aus. Deinen Antworten zufolge befindest du dich zwischen Stufe 7 und Stufe 8. 
Falls du nicht geschummelt hast 😉, müssen wir dir an dieser Stelle aufrichtige Anerkennung zollen: Diesen Bereich der „unbewussten Kompetenz“ erreichen unter 1% aller Menschen.
Hier musst du gar nicht mehr groß drüber nachdenken, um Erfolg im Leben zu realisieren. Was dich einst massive Anstrengung gekostet hat, passiert heute fast wie von selbst. 
Im letzten Fragensegment finden wir heraus, ob du eher der Stufe „Adventurer“ oder „LifeArtist“ zugehörig bist. Das ist ein großer Unterschied! Viel Spaß!
""";
        teamCharacters = ["LifeArtist.webp", "Adventurer.webp"];
        nextSet = 'LifeArtist';
      } else {
        message = """Herzlichen Glückwunsch: Du hast den zweiten Teil des Tests absolviert. 
Damit scheiden weitere 2 der möglichen Persönlichkeitsstufen für dich aus. Deinen Antworten zufolge befindest du dich zwischen Stufe 3 und Stufe 4. Dies ist der Bereich der „bewussten Inkompetenz“. Das hört sich zwar nicht schön an, damit bist du aber schon weiter als schätzungsweise drei Viertel aller Menschen. Zwar hast du noch einen langen Weg vor dir, bist aber bereits dabei, dein volles Potenzial zu erkennen. Wie nur wenige Menschen blickst du über deinen eigenen Tellerrand hinaus.
Im letzten Fragensegment finden wir heraus, ob du eher der Stufe „Explorer“ oder „Reacher“ zugehörig bist. Das ist ein großer Unterschied! Viel Spaß!
""";
        teamCharacters = ["Reacher.webp", "Explorer.webp"];
        nextSet = 'Reacher';
      }
    } else {
      if (_questions.first.set == 'BewussteKompetenz') {
        message = """Herzlichen Glückwunsch: Du hast den zweiten Teil des Tests absolviert. 
Damit scheiden weitere 2 der möglichen Persönlichkeitsstufen für dich aus. Deinen Antworten zufolge befindest du dich zwischen Stufe 5 und Stufe 6. Dies ist der Bereich der „bewussten Kompetenz“. Zwar bist du schon ungewöhnlich erfolgreich in deinem Leben, allerdings erreichst du deine Ziele noch meist nicht „wie von selbst“ (unbewusste Kompetenz) sondern teilweise unter großer Anstrengung. 
Du bist schon auf einem sehr hohen Level der Persönlichkeitsentwicklung, dass nur die wenigsten Menschen in ihrem Leben erreichen. Im letzten Fragensegment finden wir heraus, ob du eher der Stufe „Traveller“ oder „Individual“ zugehörig bist. Das ist ein großer Unterschied! Viel Spaß!
""";
        teamCharacters = ["Individual.webp", "Traveller.webp"];
        nextSet = 'Individual';
      } else {
        message =
        """Herzlichen Glückwunsch: Du hast den zweiten Teil des Tests absolviert. 
Damit scheiden weitere 2 der möglichen Persönlichkeitsstufen für dich aus. Deinen Antworten zufolge befindest du dich zwischen Stufe 1 und Stufe 2. Du befindest dich damit (wie über drei Viertel aller Menschen) im Bereich der „unbewussten Inkompetenz“. Das hört sich zwar nicht schön an, bedeutet aber eigentlich nur, dass du dein volles Potenzial noch nicht erkannt hast. Es gibt also noch viel zu entdecken.
Im letzten Fragensegment finden wir heraus, ob du eher der Stufe „Anonymous“ oder „Resident“ zugehörig bist. Das ist ein großer Unterschied! Viel Spaß!
""";
        teamCharacters = ["Resident.webp", "Anonymous.webp"];
        nextSet = 'Resident';
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFC7C7C7),
          title: SelectableText(
            '$progressScore von 850 Punkte erreicht',
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(
                  message +
                      '\n\nWinston Churchill: "Erfolg ist nicht endgültig, Misserfolg ist nicht fatal: Es ist der Mut, weiterzumachen, der zählt."\n',
                  style: TextStyle(fontFamily: 'Roboto',
                      fontSize: 18),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: teamCharacters
                        .map((character) =>
                        Image.asset('assets/$character',
                            width: 150, height: 150))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCB9935),
                elevation: 0,
                shape: RoundedRectangleBorder( // Create square corners
                  borderRadius: BorderRadius.all(
                      Radius.circular(8.0)), // No rounded corners
                ),
              ),
              onPressed: () {
                loadQuestions(nextSet);
                _isSecondTestCompleted = true;
                _currentPage = 0;
                _answers = List<int?>.filled(_questions.length, 5);
                notifyListeners();
                Navigator.of(context).pop();
              },
              child: Text(
                'Weiter',
                style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> loadFinalCharacterDescription(String characterName) async {
    String path = 'assets/auswertungen/$characterName.txt'; // Path to your description file
    try {
      String description = await rootBundle.loadString(path);
      return description;
    } catch (e) {
      print('Error loading description for $characterName: $e');
      return 'Beschreibung nicht verfügbar.'; // Default return if loading fails
    }
  }


  Future<void> completeFinalTest(BuildContext context) async {
    User? user = _auth.currentUser;
    exportUserAnswers(user!.uid, highestResultCollection!, _questions, _answers);
    // Generiere das Abschlussdatum als ISO 8601-String in UTC
    final String completionDate = DateTime.now().toUtc().toIso8601String();
    String finalCharacter;
    _totalScore = _answers.where((a) => a != null).fold(0, (sum, a) => sum + a!);
    final firstScore = await fetchScoreAndCount('Kompetenz');
    final secondScore = await fetchScoreAndCount((['Individual', 'Reacher', 'Resident', 'LifeArtist'].contains(_questions.first.set))?'BewussteInkompetenz' : 'BewussteKompetenz');
    int progressScore = _totalScore + firstScore['score']! + secondScore['score']!;

    // Determine final character based on score
    if (_questions.first.set == 'Individual') {
      finalCharacter =
      progressScore > 840 ? "Individual" : "Traveller";
    } else if (_questions.first.set == 'Reacher') {
      finalCharacter =
      progressScore > 780 ? "Reacher" : "Explorer";
    } else if (_questions.first.set == 'Resident') {
      finalCharacter =
      progressScore > 540 ? "Resident" : "Anonymous";
    } else {
      finalCharacter =
      _totalScore > 1050 ? "LifeArtist" : "Adventurer";
    }

    // Load the final character's description
    String finalCharacterDescription = await loadFinalCharacterDescription(finalCharacter);

    // Update final character and description in the model
    _finalCharacter = finalCharacter;
    _finalCharacterDescription = finalCharacterDescription;
    notifyListeners();


    try {
      // Save final character and description to Firestore
      User? user = _auth.currentUser;


      if (highestResultCollection == null) {
        print("No result collections found.");
        return;
      }
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(highestResultCollection!)
            .doc('finalCharacter')
            .set({
          'finalCharacter': _finalCharacter,
          'finalCharacterDescription': _finalCharacterDescription,
          // Add the combined total score here
          'completionDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));


        await calculateCombinedTotalScore(user.uid,highestResultCollection!);

        await exportUserResults(completionDate: completionDate,finalCharacter: _finalCharacter!, userUuid: user.uid, resultsX: highestResultCollection!, combinedTotalScore: combinedTotalScore, finalCharacterDescription: _finalCharacterDescription!);
        updateUserFirestore(currentCompletionDate: completionDate, userUuid: user.uid, currentFinalCharacterDescription:_finalCharacterDescription, currentCombinedTotalScore: combinedTotalScore, currentFinalCharacter: _finalCharacter!);

      }

    } catch (error) {
      print("Error saving final character to highest result collection: $error");
    }

    await aggregateLebensbereiche(userUuid: user.uid, resultsX: highestResultCollection!);

    String greetingText = 'Gratulation';

    final gsUrl1 = 'gs://personality-score.appspot.com/JingleKomprimiert.mp4';


    showFinalResultDialog(
        context, finalCharacter, finalCharacterDescription, greetingText,
        combinedTotalScore, gsUrl1);
  }



  void showSignInDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => SignInDialog(
        emailController: emailController,
        passwordController: passwordController,
        allowAnonymous: false,
        nextRoute: '/questionnaire',
      ),
    ).then((_) {
      // Dispose controllers when the dialog is closed
      emailController.dispose();
      passwordController.dispose();
    });
  }


  Future<void> showFinalResultDialog(
      BuildContext context,
      String finalCharacter,
      String finalCharacterDescription,
      String greetingText,
      int combinedTotalScore,
      String videoStorageUrl,
      ) async {
    // Zustandsvariablen
    bool isExpanded = false;
    double rating = 0.0;
    VideoPlayerController? _videoController;
    bool showContent = false; // Steuert die Sichtbarkeit der Inhalte
    bool isDialogActive = true; // Verfolgt, ob der Dialog noch geöffnet ist

    // Video-Controller initialisieren
    String videoUrl;
    try {
      final storage = FirebaseStorage.instance;
      videoUrl = await storage.refFromURL(videoStorageUrl).getDownloadURL();
    } catch (e) {
      print('Fehler beim Laden der Video-URL: $e');
      videoUrl = ''; // Fehlerbehandlung
    }

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    await _videoController.initialize();
    _videoController.play();

    // Dialog anzeigen
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        // Dynamic sizes based on the screen
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;
        double dialogWidth = screenWidth * 0.6;
        double dialogHeight = screenHeight * 0.7;

        return AlertDialog(
          backgroundColor: Color(0xFFC7C7C7),
          title: SelectableText(
            '$greetingText, du hast es geschafft!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Start timer to show content after 14 seconds
              Future.delayed(Duration(seconds: 14), () {
                if (isDialogActive) {
                  setState(() {
                    showContent = true;
                  });
                }
              });

              return Container(
                width: dialogWidth,
                height: dialogHeight,
                child: SingleChildScrollView(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main content
                      AnimatedOpacity(
                        opacity: showContent ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 500),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Content for logged-in users
                            SelectableText(
                              "Du hast ${combinedTotalScore} Prozent deines Potentials erreicht!\nDamit bist du ein $finalCharacter.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            SizedBox(height: 10),
                            Image.asset(
                              'assets/$finalCharacter.webp',
                              width: 200,
                              height: 200,
                            ),
                            SizedBox(height: 10),
                            // Expandable description
                            isExpanded
                                ? Container(
                              height: 150,
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  finalCharacterDescription,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                                : SelectableText(
                              finalCharacterDescription
                                  .split(' ')
                                  .take(15)
                                  .join(' ') +
                                  '...',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 32.0),
                                backgroundColor: isExpanded
                                    ? Colors.black
                                    : Color(0xFFCB9935),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Text(
                                isExpanded ? 'Lese weniger' : 'Lese mehr',
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Wie sehr identifizierst du dich mit diesem Ergebnis?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            SizedBox(height: 10),
                            RatingBar.builder(
                              initialRating: rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemPadding:
                              EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (newRating) {
                                setState(() {
                                  rating = newRating;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xFFCB9935),
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              onPressed: () async {
                                // Save rating
                                await saveUserRating(rating);
                                Navigator.of(context).pop();
                                _videoController
                                    ?.dispose(); // Release video controller

                                Navigator.of(context).pushNamed('/home');
                              },
                              child: Text(
                                'Abschließen',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Roboto'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Video Overlay
                      IgnorePointer(
                        ignoring: true, // Prevent interaction with the video
                        child: AnimatedOpacity(
                          opacity: showContent ? 0.0 : 1.0,
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            width: dialogWidth,
                            height: dialogHeight * 0.9,
                            color: Colors.transparent,
                            child: _videoController != null &&
                                _videoController!.value.isInitialized
                                ? ClipRect(
                              child: OverflowBox(
                                alignment: Alignment.center,
                                minWidth: 0.0,
                                minHeight: 0.0,
                                maxWidth: double.infinity,
                                maxHeight: double.infinity,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _videoController!
                                        .value.size.width,
                                    height: _videoController!
                                        .value.size.height,
                                    child:
                                    VideoPlayer(_videoController!),
                                  ),
                                ),
                              ),
                            )
                                : SizedBox(), // Or any placeholder widget
                          ),
                        ),
                      ),

                      // Skip Button
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: AnimatedOpacity(
                          opacity: showContent ? 0.0 : 1.0,
                          duration: Duration(milliseconds: 500),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(12.0),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                showContent = true; // Show content
                              });
                              _videoController?.pause(); // Pause the video
                              _videoController?.setVolume(0); // Mute the video sound
                              Future.delayed(Duration(milliseconds: 500), () {
                                _videoController
                                    ?.dispose(); // Dispose of the video completely
                                _videoController = null;
                              });
                            },
                            child: Icon(
                              Icons.arrow_forward, // Arrow icon instead of text
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((_) {
      isDialogActive = false; // Mark the dialog as inactive
      _videoController?.dispose(); // Release video controller
    });
  }


  Future<void> saveUserRating(double rating) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {


        if (highestResultCollection != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(highestResultCollection!)
              .doc('finalCharacter')
              .set({
            'userRating': rating,
            'ratingDate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          print("User rating saved to $highestResultCollection");
        } else {
          print("No result collections found to save user rating.");
        }
      } catch (e) {
        print('Error saving user rating: $e');
      }
    }
  }

  Future<int> getFirstScore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {


        if (highestResultCollection != null) {
          // Fetch the highest result collection for the "Kompetenz" test
          final firstTestDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(highestResultCollection!)
              .doc('Kompetenz') // Assuming "Kompetenz" is a fixed test name
              .get();

          return firstTestDoc.exists && firstTestDoc.data() != null
              ? firstTestDoc.data()!['totalScore'] ?? 0
              : 0;
        }
      } catch (error) {
        print("Error fetching first score: $error");
      }

    }
    return 0;
  }

  // Helper function to retrieve score and question count
  Future<Map<String, int>> fetchScoreAndCount(String docId) async {
    User? user = _auth.currentUser;
    if (user == null) return {'score': 0, 'questions': 0};



    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(highestResultCollection!)
        .doc(docId)
        .get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return {
        'score': data['totalScore'] ?? 0,
        'questions': data['answers']?.length ?? 0,
      };
    }
    return {'score': 0, 'questions': 0};
  }



  Future<void> calculateCombinedTotalScore(
      String userUuid,String resultCollectionName) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {


      // Determine the second test set based on the final character
      String secondTestSet = (_finalCharacter == 'LifeArtist' ||
          _finalCharacter == 'Adventurer' ||
          _finalCharacter == 'Individual' ||
          _finalCharacter == 'Traveller')
          ? 'BewussteKompetenz'
          : 'BewussteInkompetenz';

      // Fetch data for all tests
      final firstTest = await fetchScoreAndCount('Kompetenz');
      final secondTest = await fetchScoreAndCount(secondTestSet);
      final finalTest = await fetchScoreAndCount(_questions.first.set);

      // Calculate combined total score
      int totalScore = firstTest['score']! + secondTest['score']! + finalTest['score']!;
      int totalQuestions = firstTest['questions']! +
          secondTest['questions']! +
          finalTest['questions']!;

      combinedTotalScore = totalQuestions > 0
          ? ((totalScore / totalQuestions) * 10).round()
          : 0;


      if (highestResultCollection != null) {
        // Save combined score to Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(highestResultCollection!)
            .doc('finalCharacter')
            .set({
          'combinedTotalScore': combinedTotalScore,
          'lastUpdated': FieldValue.serverTimestamp(),
          'finalScores': "{$firstTest['score']}, ${secondTest['score']}, ${finalTest['score']}",
        }, SetOptions(merge: true));
      }

      // Notify listeners about the score update
      notifyListeners();
    } catch (error, stackTrace) {
      print("Error calculating combined total score: $error");
      print(stackTrace);
    }
  }



  Map<String, dynamic> prepareData(String resultsX, String userUuid) {
    List<Map<String, dynamic>> answersWithIds = [];

    for (int i = 0; i < _questions.length; i++) {
      String frageId = _questions[i].id as String; // Ensure each question has a unique 'id'
      int? answer = _answers[i];

      if (frageId.isNotEmpty && answer != null) {
        answersWithIds.add({
          'FrageID': frageId,
          'Answer': answer.toString(), // Convert to string if needed
        });
      }
    }

    return {
      'resultsX': resultsX,
      'userUuid': userUuid,
      'answers': answersWithIds,
    };
  }

  // Inside your QuestionnaireModel class
  Future<void> exportAnswersToBigQuery(String resultsX) async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not authenticated.");
    }

    String userUuid = user.uid;

    // Prepare the data payload
    Map<String, dynamic> data = prepareData(resultsX, userUuid);

    // Cloud Function URL (replace with your actual endpoint)
    final String cloudFunctionUrl = 'https://us-central1-personality-score.cloudfunctions.net/exportAnswersToBigQuery';

    try {
      // Send POST request to the Cloud Function
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if your Cloud Function requires them
          // 'Authorization': 'Bearer YOUR_AUTH_TOKEN',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Successfully inserted into BigQuery
        print('Successfully exported answers to BigQuery.');
      } else {
        // Handle server errors
        print('Failed to export answers. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to export answers to BigQuery.');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error exporting answers to BigQuery: $e');
      throw Exception('Error exporting answers to BigQuery: $e');
    }
  }

  void showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Fehler',
            style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Color(0xFFCB9935)),
              ),
            ),
          ],
        );
      },
    );
  }


}