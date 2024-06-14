import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'services/question_service.dart';
import 'models/question.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Questionnaire App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (_) => QuestionnaireModel(),
        child: QuestionnaireScreen(),
      ),
    );
  }
}

class QuestionnaireModel with ChangeNotifier {
  final QuestionService _questionService = QuestionService();
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _totalScore = 0;
  int _currentPage = 0;
  List<int?> _answers = [];
  String? _personalityType;
  int _progress = 0;
  bool _isFirstTestCompleted = false;
  bool _isSecondTestCompleted = false;

  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalScore => _totalScore;
  int get currentPage => _currentPage;
  List<int?> get answers => _answers;
  String? get personalityType => _personalityType;
  int get progress => _progress;
  bool get isFirstTestCompleted => _isFirstTestCompleted;
  bool get isSecondTestCompleted => _isSecondTestCompleted;

  Future<void> loadQuestions(String set) async {
    _questions = await _questionService.loadQuestions(set);
    _answers = List<int?>.filled(_questions.length, null);
    notifyListeners();
  }

  void answerQuestion(int index, int value) {
    _answers[index] = value;
    _totalScore = _answers.where((a) => a != null).fold(0, (sum, a) => sum + a!);
    notifyListeners();
  }

  void nextPage(BuildContext context) {
    _currentPage++;
    notifyListeners();
  }

  void prevPage() {
    if (_currentPage > 0) {
      _currentPage--;
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
    notifyListeners();
  }

  double getProgress() {
    if (_questions.isEmpty) return 0.0;
    return (_currentPage + 1) / (_questions.length / 7).ceil();
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
      teamCharacters = ["Resident.webp", "Explorer.webp", "Reacher.webp", "Anonymous.webp"];
      nextSet = 'BewussteInkompetenz';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: teamCharacters.map((character) => Image.asset('assets/$character', width: 100, height: 100)).toList(),
              ),
            ],
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
        teamCharacters = ["Resident.webp", "Anonymous.webp"];
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: teamCharacters.map((character) => Image.asset('assets/$character', width: 150, height: 150)).toList(),
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

  void completeFinalTest(BuildContext context) {
    String finalCharacter;
    String finalCharacterDescription;

    int possibleScore = _questions.length * 3; // Calculate possible score for the final set

    if (_questions.first.set == 'Traveller') {
      if (_totalScore > (possibleScore * 0.5)) {
        finalCharacter = "Traveller.webp";
        finalCharacterDescription = """Als ständiger Abenteurer strebt der Traveller nach neuen Erfahrungen und persönlichem Wachstum, stets begleitet von Neugier und Offenheit.
Er inspiriert durch seine Entschlossenheit, das Leben in vollen Zügen zu genießen und sich kontinuierlich weiterzuentwickeln.""";
      } else {
        finalCharacter = "Individual.webp";
        finalCharacterDescription = """Der Individual strebt nach Klarheit und Verwirklichung seiner Ziele, beeindruckt durch Selbstbewusstsein und klare Entscheidungen.
Er inspiriert andere durch seine Entschlossenheit und positive Ausstrahlung.""";
      }
      }
    else if (_questions.first.set == 'Reacher') {
      if (_totalScore > (possibleScore * 0.5)) {
        finalCharacter = "Reacher.webp";
        finalCharacterDescription = """Als Initiator der Veränderung strebt der Reacher nach Wissen und persönlicher Entwicklung, trotz der Herausforderungen und Unsicherheiten.
Seine Motivation und innere Stärke führen ihn auf den Weg des persönlichen Wachstums.""";
      } else {
        finalCharacter = "Explorer.webp";
        finalCharacterDescription = """Immer offen für neue Wege der Entwicklung, erforscht der Explorer das Unbekannte und gestaltet sein Leben aktiv.
Seine Offenheit und Entschlossenheit führen ihn zu neuen Ideen und persönlichem Wachstum.""";
      }
    }
    else if  (_questions.first.set == 'Resident') {
      if (_totalScore < (possibleScore * 0.5)) {
        finalCharacter = "Resident.webp";
        finalCharacterDescription = """Im ständigen Kampf mit inneren Dämonen sucht der Resident nach persönlichem Wachstum und Klarheit, unterstützt andere trotz eigener Herausforderungen.
Seine Erfahrungen und Wissen bieten Orientierung, während er nach Selbstvertrauen und Stabilität strebt.""";
      } else {
        finalCharacter = "Anonymous.webp";
        finalCharacterDescription = """Der Anonymous operiert im Verborgenen, mit einem tiefen Weitblick und unaufhaltsamer Ruhe, beeinflusst er subtil aus dem Schatten.
Sein unsichtbares Netzwerk und seine Anpassungsfähigkeit machen ihn zum verlässlichen Berater derjenigen im Rampenlicht.""";
      }
    }
    else {
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

    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Final Character'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your final character is:'),
              SizedBox(height: 10),
              Image.asset('assets/$finalCharacter', width: 200, height: 200),
              SizedBox(height: 10),
              Text(finalCharacterDescription),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email to receive results',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Send email logic here (this is a placeholder)
                String email = 'My final character is $finalCharacter.\n\nDescription: $finalCharacterDescription';
                print('Send results to: $email');
                Navigator.of(context).pop();
                reset(); // Reset the quiz
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


  void setPersonalityType(String type) {
    _personalityType = type;
    notifyListeners();
  }
}

class QuestionnaireScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questionnaire'),
      ),
      body: Consumer<QuestionnaireModel>(
        builder: (context, model, child) {
          if (model.questions.isEmpty) {
            model.loadQuestions('Kompetenz'); // Load initial questions based on set name
            return Center(child: CircularProgressIndicator());
          }

          int start = model.currentPage * 7;
          int end = start + 7;
          List<Question> currentQuestions = model.questions.sublist(start, end > model.questions.length ? model.questions.length : end);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Personality Score',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              LinearProgressIndicator(
                value: model.getProgress(),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestions.length,
                  itemBuilder: (context, index) {
                    Question question = currentQuestions[index];
                    int questionIndex = start + index;
                    return ListTile(
                      title: Center(child: Text(question.text)),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (i) {
                          return Expanded(
                            child: RadioListTile<int>(
                              value: i,
                              groupValue: model.answers[questionIndex],
                              onChanged: (val) {
                                if (val != null) {
                                  model.answerQuestion(questionIndex, val);
                                }
                              },
                              title: Center(child: Text(i.toString())), // Display 0-3
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (model.currentPage > 0)
                    ElevatedButton(
                      onPressed: () => model.prevPage(),
                      child: Text('Previous'),
                    ),
                  if (end < model.questions.length)
                    ElevatedButton(
                      onPressed: () => model.nextPage(context),
                      child: Text('Next'),
                    ),
                  if (end >= model.questions.length && !model.isFirstTestCompleted)
                    ElevatedButton(
                      onPressed: () => model.completeFirstTest(context),
                      child: Text('Complete First Test'),
                    ),
                  if (end >= model.questions.length && model.isFirstTestCompleted && !model.isSecondTestCompleted)
                    ElevatedButton(
                      onPressed: () {
                        model.completeSecondTest(context);
                        _showRewardAnimation(context, 'stars.json'); // Show reward animation
                      },
                      child: Text('Complete Second Test'),
                    ),
                  if (end >= model.questions.length && model.isSecondTestCompleted)
                    ElevatedButton(
                      onPressed: () {
                        model.completeFinalTest(context);
                        _showRewardAnimation(context, 'stars.json'); // Show reward animation
                      },
                      child: Text('Finish Final Test'),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRewardAnimation(BuildContext context, String animationAsset) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 1), () {
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
