import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personality_score/services/question_service.dart';
import 'package:personality_score/models/question.dart';
import 'package:share_plus/share_plus.dart';

class QuestionnaireModel with ChangeNotifier {
  QuestionService _questionService = QuestionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _totalScore = 0;
  int _currentPage = 0;
  List<int?> _answers = [];
  String? _personalityType;
  int _progress = 0;
  bool _isFirstTestCompleted = false;
  bool _isSecondTestCompleted = false;
  String _currentSet = 'Kompetenz';

  String? _finalCharacter;
  String? _finalCharacterDescription;

  set questionService(QuestionService service) {
    _questionService = service;
  }

  List<Question> get questions => _questions;

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

  Future<void> loadQuestions(String set) async {
    _currentSet = set;
    // Load questions from the service
    List<Question> loadedQuestions = await _questionService.loadQuestions(set);

    // Create a Set to store unique questions
    Set<String> uniqueQuestionTexts = {};
    List<Question> uniqueQuestions = [];

    for (var question in loadedQuestions) {
      if (uniqueQuestionTexts.add(question
          .text)) { // Assuming `text` is the unique identifier for the question
        uniqueQuestions.add(question);
      }
    }

    _questions = uniqueQuestions;
    _answers = List<int?>.filled(_questions.length, null);
    notifyListeners();
  }

  Future<void> saveProgress() async {
    User? user = _auth.currentUser;
    if (user != null) {
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
      }, SetOptions(merge: true));
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
            data['answers'] ?? List<int?>.filled(_questions.length, null));
        _finalCharacter = data['finalCharacter'];
        _finalCharacterDescription = data['finalCharacterDescription'];
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

  void nextPage(BuildContext context) {
    if ((_currentPage + 1) * 7 < _questions.length) {
      _currentPage++;
      saveProgress();
      notifyListeners();
    }
  }

  void resetQuestionnaire() {
    _answers = List<int?>.filled(_questions.length, null);
    _currentPage = 0;
    _totalScore = 0;
    _isFirstTestCompleted = false;
    _isSecondTestCompleted = false;
    saveProgress();
    notifyListeners();
  }

  void continueFromLastPage() {
    // This function just notifies listeners since the currentPage is already loaded
    notifyListeners();
  }


  void prevPage() {
    if (_currentPage > 0) {
      _currentPage--;
      saveProgress();
      notifyListeners();
    }
  }

  void reset() {
    _totalScore = 0;
    _currentQuestionIndex = 0;
    _currentPage = 0;
    _progress = 0;
    _answers = List<int?>.filled(_questions.length, null);
    _personalityType = null;
    _isFirstTestCompleted = false;
    _isSecondTestCompleted = false;
    saveProgress();
    notifyListeners();
  }

  double getProgress() {
    if (_questions.isEmpty) return 0.0;
    return (_currentPage + 1) / (_questions.length / 7).ceil();
  }

  void setPersonalityType(String type) {
    _personalityType = type;
    saveProgress();
    notifyListeners();
  }

  void completeFirstTest(BuildContext context) {
    _isFirstTestCompleted = true;
    String message;
    List<String> teamCharacters;
    String nextSet;

    int possibleScore = _questions.length *
        3; // Calculate possible score for the current set

    if (_totalScore > (possibleScore *
        0.5)) { // Check if total score is more than 50% of possible score
      message =
      """Herzlichen Glückwunsch: Du hast den ersten Teil des Tests absolviert. 
      Damit scheiden 4 von 8 möglichen Persönlichkeitsstufen für dich aus. Deinen Antworten zufolge befindest du dich zwischen Stufe 1 und Stufe 4. Noch hast du wahre „Lebenskompetenz“ (diese beginnt ab Stufe 5) nicht erreicht, sondern befindest dich auf dem Weg dahin. Das ist aber überhaupt nicht schlimm, sondern völlig normal. Wir gehen davon aus, dass über 90% der Menschen auf den Stufen 1 bis 4 zu verorten sind.
    Im nächsten Fragensegment engen wir dein Ergebnis noch weiter ein. Viel Spaß!
    """;
      teamCharacters = [
        "Life Artist.webp",
        "Individual.webp",
        "Adventurer.webp",
        "Traveller.webp"
      ];
      nextSet = 'BewussteKompetenz';
    } else {
      message ="""Herzlichen Glückwunsch: Du hast den ersten Teil des Tests absolviert. 
Damit scheiden 4 von 8 möglichen Persönlichkeitsstufen für dich aus. Deinen Antworten zufolge befindest du dich zwischen Stufe 5 und Stufe 8. Damit hast du bereits echte „Lebenskompetenz“ erreicht und gehörst damit bereits zu einer kleinen Minderheit. Wir gehen davon aus, dass über 90% der Menschen auf den Stufen 1 bis 4 im Bereich der „Inkompetenz“ zu verorten sind. Für deine bisherige Entwicklung also schonmal ein dickes Lob.
Im nächsten Fragensegment engen wir dein Ergebnis noch weiter ein. Viel Spaß!
""";
    teamCharacters =
      ["resident.webp", "Explorer.webp", "Reacher.webp", "Anonymous.webp"];
      nextSet = 'BewussteInkompetenz';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF7F5EF), // Soft background
          title: Text('$_totalScore Punkte erreicht', style: TextStyle(color: Colors.black, fontFamily: 'Roboto')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, style: TextStyle(color: Colors.black, fontFamily: 'Roboto')),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.center,
                  children: teamCharacters
                      .map((character) => Image.asset('assets/$character', width: 100, height: 100))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFCB9935), // Gold background for the button
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder( // Create square corners
                  borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
                ),
              ),
              onPressed: () {
                loadQuestions(nextSet);
                _currentPage = 0;
                _totalScore = 0;
                _answers = List<int?>.filled(_questions.length, null);
                notifyListeners();
                Navigator.of(context).pop();
              },
              child: Text('Next', style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
            ),
          ],
        );
      },
    );
  }


  void completeSecondTest(BuildContext context) {
    _isSecondTestCompleted = true;
    String message;
    List<String> teamCharacters;
    String nextSet;

    int possibleScore = _questions.length *
        3; // Calculate possible score for the current set

    if (_totalScore > (possibleScore *
        0.5)) { // Check if total score is more than 50% of possible score
      if (_questions.first.set == 'BewussteKompetenz') {
        message ="""Herzlichen Glückwunsch: Du hast den zweiten Teil des Tests absolviert. Damit scheiden weitere 2 der möglichen Persönlichkeitsstufen für dich aus. Deinen Antworten zufolge befindest du dich zwischen Stufe 7 und Stufe 8. 
Falls du nicht geschummelt hast 😉, müssen wir dir an dieser Stelle aufrichtige Anerkennung zollen: Diesen Bereich der „unbewussten Kompetenz“ erreichen unter 1% aller Menschen.
Hier musst du gar nicht mehr groß drüber nachdenken, um Erfolg im Leben zu realisieren. Was dich einst massive Anstrengung gekostet hat, passiert heute fast wie von selbst. 
Im letzten Fragensegment finden wir heraus, ob du eher der Stufe „Adventurer“ oder „Life Artist“ zugehörig bist. Das ist ein großer Unterschied! Viel Spaß!
""";
        teamCharacters = ["Life Artist.webp", "Adventurer.webp"];
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
        teamCharacters = ["resident.webp", "Anonymous.webp"];
        nextSet = 'Resident';
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF7F5EF),
          title: Text(
            '$_totalScore Punkte erreicht',
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: teamCharacters
                        .map((character) => Image.asset('assets/$character',
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
                  borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
                ),
              ),
              onPressed: () {
                loadQuestions(nextSet);
                _currentPage = 0;
                _totalScore = 0;
                _answers = List<int?>.filled(_questions.length, null);
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

  void completeFinalTest(BuildContext context) async {
    String finalCharacter;
    String finalCharacterDescription;

    int possibleScore = _questions.length *
        3; // Calculate possible score for the final set

    if (_questions.first.set == 'Individual') {
      if (_totalScore > (possibleScore * 0.5)) {
        finalCharacter = "Individual.webp";
        finalCharacterDescription = """Der Individual strebt nach Klarheit und Verwirklichung seiner Ziele, beeindruckt durch Selbstbewusstsein und klare Entscheidungen.
Er inspiriert andere durch seine Entschlossenheit und positive Ausstrahlung.""";
      } else {
        finalCharacter = "Traveller.webp";
        finalCharacterDescription = """Als ständiger Abenteurer strebt der Traveller nach neuen Erfahrungen und persönlichem Wachstum, stets begleitet von Neugier und Offenheit.
Er inspiriert durch seine Entschlossenheit, das Leben in vollen Zügen zu genießen und sich kontinuierlich weiterzuentwickeln.""";
      }
    } else if (_questions.first.set == 'Reacher') {
      if (_totalScore > (possibleScore * 0.5)) {
        finalCharacter = "Reacher.webp";
        finalCharacterDescription = """Als Initiator der Veränderung strebt der Reacher nach Wissen und persönlicher Entwicklung, trotz der Herausforderungen und Unsicherheiten.
Seine Motivation und innere Stärke führen ihn auf den Weg des persönlichen Wachstums.""";
      } else {
        finalCharacter = "Explorer.webp";
        finalCharacterDescription = """Immer offen für neue Wege der Entwicklung, erforscht der Explorer das Unbekannte und gestaltet sein Leben aktiv.
Seine Offenheit und Entschlossenheit führen ihn zu neuen Ideen und persönlichem Wachstum.""";
      }
    } else if (_questions.first.set == 'Resident') {
      if (_totalScore > (possibleScore * 0.5)) {
        finalCharacter = "resident.webp";
        finalCharacterDescription = """Im ständigen Kampf mit inneren Dämonen sucht der Resident nach persönlichem Wachstum und Klarheit, unterstützt andere trotz eigener Herausforderungen.
Seine Erfahrungen und Wissen bieten Orientierung, während er nach Selbstvertrauen und Stabilität strebt.""";
      } else {
        finalCharacter = "Anonymous.webp";
        finalCharacterDescription = """Der Anonymous operiert im Verborgenen, mit einem tiefen Weitblick und unaufhaltsamer Ruhe, beeinflusst er subtil aus dem Schatten.
Sein unsichtbares Netzwerk und seine Anpassungsfähigkeit machen ihn zum verlässlichen Berater derjenigen im Rampenlicht.""";
      }
    } else {
      if (_totalScore > (possibleScore * 0.5)) {
        finalCharacter = "Life Artist.webp";
        finalCharacterDescription = """Der Life Artist lebt seine Vision des Lebens mit Dankbarkeit und Energie, verwandelt Schwierigkeiten in bedeutungsvolle Erlebnisse.
Seine Gelassenheit und Charisma ziehen andere an, während er durch ein erfülltes Leben inspiriert.""";
      } else {
        finalCharacter = "Adventurer.webp";
        finalCharacterDescription = """Der Adventurer meistert das Leben mit Leichtigkeit und fasziniert durch seine Ausstrahlung und Selbstsicherheit, ein Magnet für Erfolg und Menschen.
Kreativ und strukturiert erreicht er seine Ziele in einem Leben voller spannender Herausforderungen.""";
      }
    }

    // Set final character and description in model
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
        'completionDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('results')
          .doc(_currentSet)
          .set({
        'set': _currentSet,
        'totalScore': _totalScore,
        'isCompleted': true,
        'completionDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF7F5EF),
          // Background color for consistency
          title: Text('Deine Persönlichkeitsstufe',
              style: TextStyle(color: Colors.black, fontFamily: 'Roboto')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Dein Finaler Charakter:', style: TextStyle(
                    color: Colors.black, fontFamily: 'Roboto')),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.center,
                  children: [
                    Image.asset(
                        'assets/$finalCharacter', width: 200, height: 200),
                  ],
                ),
                SizedBox(height: 10),
                Text(finalCharacterDescription, style: TextStyle(
                    color: Colors.black, fontFamily: 'Roboto')),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFCB9935),
                // Gold background for finish button
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder( // Create square corners
                  borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
                ),
              ),
              onPressed: () {
                reset();
                Navigator.of(context).pop();
              },
              child: Text('Finish',
                  style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                // Transparent for the share button
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder( // Create square corners
                  borderRadius: BorderRadius.all(Radius.circular(8.0)), // No rounded corners
                ),
              ),
              onPressed: () {
                String shareText = 'Du bist ein $finalCharacter.\n\nDescription: $finalCharacterDescription';
                Share.share(shareText);
              },
              child: Text('Share', style: TextStyle(
                  color: Color(0xFFCB9935), fontFamily: 'Roboto')),
            ),
          ],
        );
      },
    );
  }
}