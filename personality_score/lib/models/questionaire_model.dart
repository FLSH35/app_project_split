import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personality_score/services/question_service.dart';
import 'package:personality_score/models/question.dart';
import 'package:share_plus/share_plus.dart';

class QuestionnaireModel with ChangeNotifier {
  QuestionService _questionService = QuestionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;

  int score_factor = 0;


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


  /// Loading questions from the service
  Future<void> loadQuestions(String set) async {
    _isLoading = true; // Set loading to true while fetching data
    notifyListeners(); // Notify listeners to update the UI

    _currentSet = set;

    try {
      // Load questions from the service
      List<Question> loadedQuestions = await _questionService.loadQuestions(
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


  Future<void> saveProgress() async {
    _isLoading = true; // Start loading
    notifyListeners(); // Notify listeners to show loading spinner

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('results')
            .doc(_currentSet)
            .set({
          'set': _currentSet,
          'totalScore': _totalScore,
          'isCompleted': _isFirstTestCompleted || _isSecondTestCompleted,
          'completionDate': FieldValue.serverTimestamp(),
          'currentPage': _currentPage,
          'answers': _answers,
          'combinedTotalScore': combinedTotalScore,
        }, SetOptions(merge: true));
      } catch (error) {
        print("Error saving progress: $error");
      } finally {
        _isLoading = false; // Stop loading after the save operation completes
        notifyListeners(); // Notify listeners to hide loading spinner
      }
    }
  }


  Future<void> loadProgress() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('results')
          .doc(_currentSet)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _totalScore = data['totalScore'];
        _isFirstTestCompleted = data['isCompleted'];
        _currentPage = data['currentPage'] ?? 0;
        _answers = List<int?>.from(
            data['answers'] ?? List<int?>.filled(_questions.length, 5));
        _finalCharacter = data['finalCharacter'];
        _finalCharacterDescription = data['finalCharacterDescription'];
        combinedTotalScore = data['_combinedTotalScore'];
        notifyListeners();
      }
    }
  }

  void answerQuestion(int index, int value) {
    _answers[index] = value;
    _totalScore =
        _answers.where((a) => a != null).fold(0, (sum, a) => sum + a!);
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

  void completeFirstTest(BuildContext context) {
    score_factor += _questions.length;


    String message;
    List<String> teamCharacters;
    String nextSet;

    int possibleScore = _questions.length *
        10; // Calculate possible score for the current set

    if (_totalScore > (possibleScore *
        0.65)) { // Check if total score is more than 50% of possible score
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

      teamCharacters =
      ["Resident.webp", "Explorer.webp", "Reacher.webp", "Anonymous.webp"];
      nextSet = 'BewussteInkompetenz';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFC7C7C7), // Soft background
          title: Text('$_totalScore Punkte erreicht',
              style: TextStyle(color: Colors.black, fontFamily: 'Roboto')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(message +
                    '\n\n Thomas A. Edison: "Viele Menschen, die im Leben scheitern, sind Menschen, die nicht erkennen, wie nah sie am Erfolg waren, als sie aufgaben."\n'
                    ,
                    style: TextStyle(color: Colors.black, fontFamily: 'Roboto',
                        fontSize: 18)),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.center,
                  children: teamCharacters
                      .map((character) =>
                      Image.asset('assets/$character', width: 100, height: 100))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFCB9935),
                // Gold background for the button
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder( // Create square corners
                  borderRadius: BorderRadius.all(
                      Radius.circular(8.0)), // No rounded corners
                ),
              ),
              onPressed: () {
                loadQuestions(nextSet);
                _isFirstTestCompleted = true;
                _currentPage = 0;
                _answers = List<int?>.filled(_questions.length, 5);
                notifyListeners();
                Navigator.of(context).pop();
              },
              child: Text('Next',
                  style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
            ),
          ],
        );
      },
    );
  }


  void completeSecondTest(BuildContext context) {
    score_factor += _questions.length;

    String message;
    List<String> teamCharacters;
    String nextSet;

    int possibleScore = _questions.length *
        10; // Calculate possible score for the current set

    if (_totalScore > (possibleScore *
        0.65)) { // Check if total score is more than 50% of possible score
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
            '$_totalScore Punkte erreicht',
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
                'Next',
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

  void completeFinalTest(BuildContext context) async {
    String finalCharacter;

    int possibleScore = _questions.length *
        10; // Calculate possible score for the final set

    // Determine final character based on score
    if (_questions.first.set == 'Individual') {
      finalCharacter =
      _totalScore > (possibleScore * 0.65) ? "Individual" : "Traveller";
    } else if (_questions.first.set == 'Reacher') {
      finalCharacter =
      _totalScore > (possibleScore * 0.65) ? "Reacher" : "Explorer";
    } else if (_questions.first.set == 'Resident') {
      finalCharacter =
      _totalScore > (possibleScore * 0.5) ? "Resident" : "Anonymous";
    } else {
      finalCharacter =
      _totalScore > (possibleScore * 0.85) ? "LifeArtist" : "Adventurer";
    }

    // Load the final character's description
    String finalCharacterDescription = await loadFinalCharacterDescription(
        finalCharacter);

    // Update final character and description in the model
    _finalCharacter = finalCharacter;
    _finalCharacterDescription = finalCharacterDescription;
    notifyListeners();

    // Save final character and description to Firestore
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('results')
          .doc('finalCharacter')
          .set({
        'finalCharacter': _finalCharacter,
        'finalCharacterDescription': _finalCharacterDescription,
        // Add the combined total score here
        'completionDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await calculateCombinedTotalScore();

    // Show final result dialog
    String? name = user?.displayName;
    String greetingText = 'Lieber $name';
    showFinalResultDialog(
        context, finalCharacter, finalCharacterDescription, greetingText,
        combinedTotalScore);
  }

  void showFinalResultDialog(BuildContext context, String finalCharacter,
      String finalCharacterDescription, String greetingText,
      int combinedTotalScore) {
    bool isExpanded = false; // State variable for description expansion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFC7C7C7),
          title: Text('$greetingText, deine Persönlichkeitsstufe',
              style: TextStyle(color: Colors.black, fontFamily: 'Roboto')),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableText(
                        "Du hast ${combinedTotalScore} Prozent deines Potentials erreicht!\n Damit bist du ein $finalCharacter.",
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Roboto')),
                    SizedBox(height: 10),
                    if (!isExpanded)
                      Image.asset(
                          'assets/$finalCharacter.webp', width: 200,
                          height: 200),
                    SizedBox(height: 10),
                    // Expandable description
                    isExpanded
                        ? Container(
                      height: 150,
                      child: SingleChildScrollView(
                        child: SelectableText(finalCharacterDescription,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                fontSize: 18)),
                      ),
                    )
                        : SelectableText(
                      finalCharacterDescription.split(' ').take(15).join(' ') +
                          '...',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Roboto',
                          fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    // "Lese mehr" button with updated style
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                        backgroundColor: isExpanded ? Colors.black : Color(
                            0xFFCB9935),
                        side: BorderSide(color: Color(0xFFCB9935)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded; // Toggle the state
                        });
                      },
                      child: Text(
                        isExpanded ? 'Lese weniger' : 'Lese mehr',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFCB9935),
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/home');
                reset();
              },
              child: Text('Abschließen',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Roboto')),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              onPressed: () {
                String shareText = 'Du hast ${combinedTotalScore} Punkte. Damit bist du ein $finalCharacter.\n\nBeschreibung: $finalCharacterDescription';
                Share.share(shareText);
              },
              child: Text('Teilen', style: TextStyle(
                  color: Color(0xFFCB9935), fontFamily: 'Roboto')),
            ),
          ],
        );
      },
    );
  }

  Future<void> calculateCombinedTotalScore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Abrufen der Total-Scores vom ersten Test (Kompetenz)
        final firstTestDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('results')
            .doc('Kompetenz')
            .get();

        int firstTestScore = firstTestDoc.exists && firstTestDoc.data() != null
            ? firstTestDoc.data()!['totalScore'] ?? 0
            : 0;

        // Anzahl der Fragen im ersten Test (Kompetenz)
        int firstTestQuestionsCount = firstTestDoc.exists &&
            firstTestDoc.data() != null
            ? firstTestDoc.data()!['answers']?.length ?? 0
            : 0;

        // Abrufen der Total-Scores vom zweiten Test (abhängig vom finalCharacter)
        String secondTestSet = (_finalCharacter == 'LifeArtist' ||
            _finalCharacter == 'Adventurer' ||
            _finalCharacter == 'Individual' || _finalCharacter == 'Traveller')
            ? 'BewussteKompetenz'
            : 'BewussteInkompetenz';

        final secondTestDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('results')
            .doc(secondTestSet)
            .get();

        int secondTestScore = secondTestDoc.exists &&
            secondTestDoc.data() != null
            ? secondTestDoc.data()!['totalScore'] ?? 0
            : 0;

        // Anzahl der Fragen im zweiten Test
        int secondTestQuestionsCount = secondTestDoc.exists &&
            secondTestDoc.data() != null
            ? secondTestDoc.data()!['answers']?.length ?? 0
            : 0;

        // Abrufen der Total-Scores vom finalen Test
        final finalTestDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('results')
            .doc(_finalCharacter ?? 'FinalTest')
            .get();

        int finalTestScore = finalTestDoc.exists && finalTestDoc.data() != null
            ? finalTestDoc.data()!['totalScore'] ?? 0
            : 0;

        // Anzahl der Fragen im finalen Test
        int finalTestQuestionsCount = finalTestDoc.exists &&
            finalTestDoc.data() != null
            ? finalTestDoc.data()!['answers']?.length ?? 0
            : 0;

        // Berechnung der kombinierten Total-Scores
        int totalQuestions = firstTestQuestionsCount +
            secondTestQuestionsCount + finalTestQuestionsCount;
        if (totalQuestions > 0) {
          combinedTotalScore = ((firstTestScore + secondTestScore + finalTestScore) / totalQuestions *10).round();
        } else {
          combinedTotalScore =
          0; // Setze auf 0, wenn keine Fragen vorhanden sind
        }

        // Speichern des kombinierten Total-Scores in Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('results')
            .doc('finalCharacter')
            .set({
          'combinedTotalScore': combinedTotalScore,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Benachrichtige die Listener, dass sich der combinedTotalScore geändert hat
        notifyListeners();
      } catch (error) {
        print("Fehler beim Abrufen der Scores: $error");
      }
    }
  }
}

