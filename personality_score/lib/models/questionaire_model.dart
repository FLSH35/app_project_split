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
      if (uniqueQuestionTexts.add(question.text)) { // Assuming `text` is the unique identifier for the question
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
        _answers = List<int?>.from(data['answers'] ?? List<int?>.filled(_questions.length, null));
        _finalCharacter = data['finalCharacter'];
        _finalCharacterDescription = data['finalCharacterDescription'];
        notifyListeners();
      }
    }
  }

  void answerQuestion(int index, int value) {
    _answers[index] = value;
    _totalScore = _answers.where((a) => a != null).fold(0, (sum, a) => sum + a!);
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

    int possibleScore = _questions.length * 3; // Calculate possible score for the current set

    if (_totalScore > (possibleScore * 0.5)) { // Check if total score is more than 50% of possible score
      message = 'Im Bereich der Kompetenz hast du folgende Punktzahl: $_totalScore\n\n Jetzt kennst du dein Team. Wenn du dein wahres Ich kennenlernen willst, fülle noch die nächsten Fragen aus!';
      teamCharacters = ["Life Artist.webp", "Individual.webp", "Adventurer.webp", "Traveller.webp"];
      nextSet = 'BewussteKompetenz';
    } else {
      message = 'Im Bereich der Kompetenz hast du folgende Punktzahl: $_totalScore\n\n  Jetzt kennst du dein Team. Wenn du dein wahres Ich kennenlernen willst, fülle noch die nächsten Fragen aus!';
      teamCharacters = ["resident.webp", "Explorer.webp", "Reacher.webp", "Anonymous.webp"];
      nextSet = 'BewussteInkompetenz';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Total Score'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10.0, // Space between adjacent items
                  runSpacing: 10.0, // Space between lines
                  alignment: WrapAlignment.center, // Align items in the center
                  children: teamCharacters.map((character) => Image.asset('assets/$character', width: 100, height: 100)).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                loadQuestions(nextSet); // Load next set of questions
                _currentPage = 0;
                _totalScore = 0;
                _answers = List<int?>.filled(_questions.length, null);
                notifyListeners();
                Navigator.of(context).pop();
              },
              child: Text('Next'),
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

    int possibleScore = _questions.length * 3; // Calculate possible score for the current set

    if (_totalScore > (possibleScore * 0.5)) { // Check if total score is more than 50% of possible score
      if (_questions.first.set == 'BewussteKompetenz') {
        message = 'Your total score is: $_totalScore\n\n Bist du ein Life Artist oder ein Adventurer? Das ist ein riesiger Unteschied. Noch 5 Minuten und du findest deine Stärken und blinden Flecken heraus!';
        teamCharacters = ["Life Artist.webp", "Adventurer.webp"];
        nextSet = 'LifeArtist';
      } else {
        message = 'Your total score is: $_totalScore\n\n Bist du ein Reacher oder ein Explorer? Das ist ein riesiger Unteschied. Noch 5 Minuten und du findest deine Stärken und blinden Flecken heraus!';
        teamCharacters = ["Reacher.webp", "Explorer.webp"];
        nextSet = 'Reacher';
      }
    } else {
      if (_questions.first.set == 'BewussteKompetenz') {
        message = 'Your total score is: $_totalScore\n\n Bist du ein Individual oder ein Traveller? Das ist ein riesiger Unteschied. Noch 5 Minuten und du findest deine Stärken und blinden Flecken heraus!';
        teamCharacters = ["Individual.webp", "Traveller.webp"];
        nextSet = 'Individual';
      } else {
        message = 'Your total score is: $_totalScore\n\n Bist du ein Resident oder ein Anonymous? Das ist ein riesiger Unteschied. Noch 5 Minuten und du findest deine Stärken und blinden Flecken heraus!';
        teamCharacters = ["resident.webp", "Anonymous.webp"];
        nextSet = 'Resident';
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Total Score'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: teamCharacters.map((character) => Image.asset('assets/$character', width: 150, height: 150)).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                loadQuestions(nextSet); // Load final set of questions
                _currentPage = 0;
                _totalScore = 0;
                _answers = List<int?>.filled(_questions.length, null);
                notifyListeners();
                Navigator.of(context).pop();
              },
              child: Text('Next'),
            ),
          ],
        );
      },
    );
  }

  void completeFinalTest(BuildContext context) async {
    String finalCharacter;
    String finalCharacterDescription;

    int possibleScore = _questions.length * 3; // Calculate possible score for the final set

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
          title: Text('Final Character'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your final character is:'),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10.0, // Space between adjacent items
                  runSpacing: 10.0, // Space between lines
                  alignment: WrapAlignment.center, // Align items in the center
                  children: [
                    Image.asset('assets/$finalCharacter', width: 200, height: 200),
                  ],
                ),
                SizedBox(height: 10),
                Text(finalCharacterDescription),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                reset(); // Reset the state
                Navigator.of(context).pop();
                notifyListeners();
              },
              child: Text('Finish'),
            ),
            TextButton(
              onPressed: () {
                String shareText = 'My final character is $finalCharacter.\n\nDescription: $finalCharacterDescription';
                Share.share(shareText); // Share the result
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }
}
