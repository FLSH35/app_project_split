import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:personality_score/services/question_service.dart';
import 'package:personality_score/models/question.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../screens/pdf_viewer_screen.dart';
import '../screens/signin_dialog.dart';

class QuestionnaireModel with ChangeNotifier {
  QuestionService _questionService = QuestionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;

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


  Future<String> getHighestResultCollection() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      int maxCollectionNumber = 0;

      // Try accessing collections in sequence
      while (true) {
        final collectionName = 'results_${maxCollectionNumber + 1}';
        final collectionRef = userDocRef.collection(collectionName);

        try {
          // Attempt to get a document from the collection to check if it exists
          final snapshot = await collectionRef.limit(1).get();
          if (snapshot.docs.isNotEmpty) {
            maxCollectionNumber++;
          } else {
            break; // Exit loop if the collection doesn't exist
          }
        } catch (e) {
          // Break the loop if accessing the collection causes an error
          break;
        }
      }

      // Return the highest results collection found
      if (maxCollectionNumber == 0) {
        return 'results_1'; // Default to 'results_1' if no results exist
      }
      return 'results_$maxCollectionNumber';
    } catch (e) {
      print('Error fetching highest result collection: $e');
      return 'results_1'; // Return default in case of error
    }
  }




  Future<void> saveProgress() async {
    _isLoading = true;
    notifyListeners();

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Fetch the highest result collection name
        String? highestResultCollection = await getHighestResultCollection();

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
            .collection(highestResultCollection)
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
        String? highestResultCollection = await getHighestResultCollection();

        if (highestResultCollection != null) {
          // Fetch the data from the highest result collection
          DocumentSnapshot resultSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(highestResultCollection)
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


  Future<String> createNextResultsCollection() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      // Get the highest result collection
      String? highestResultCollection = await getHighestResultCollection();

      // Determine the next collection number
      int nextResultNumber = 1; // Default to 1 if no results exist
      if (highestResultCollection != null) {
        final match = RegExp(r'results_(\d+)').firstMatch(highestResultCollection);
        if (match != null) {
          nextResultNumber = int.parse(match.group(1)!) + 1;
        }
      }

      // Create the new collection
      String newCollectionName = 'results_$nextResultNumber';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(newCollectionName)
          .doc('finalCharacter') // Initial document
          .set({
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'initialized',
      });

      return newCollectionName;
    } catch (error) {
      print("Error creating next results collection: $error");
      throw Exception("Failed to create next results collection");
    }
  }








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

  void completeFirstTest(BuildContext context) {
    score_factor += _questions.length;


    String message;
    List<String> teamCharacters;
    String nextSet;

    int possibleScore = _questions.length *
        10; // Calculate possible score for the current set

    if (_totalScore > 275) { // Check if total score is more than 50% of possible score
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
          title: Text('$_totalScore von $possibleScore Punkte erreicht',
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
              child: Text('Weiter',
                  style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
            ),
          ],
        );
      },
    );
  }


  Future<void> completeSecondTest(BuildContext context) async {
    score_factor += _questions.length;

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


  void completeFinalTest(BuildContext context) async {
    String finalCharacter;

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
    String finalCharacterDescription = await loadFinalCharacterDescription(
        finalCharacter);

    // Update final character and description in the model
    _finalCharacter = finalCharacter;
    _finalCharacterDescription = finalCharacterDescription;
    notifyListeners();


    try {
      // Get the highest result collection
      String? highestResultCollection = await getHighestResultCollection();

      if (highestResultCollection == null) {
        print("No result collections found.");
        return;
      }
      // Save final character and description to Firestore
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(highestResultCollection)
            .doc('finalCharacter')
            .set({
          'finalCharacter': _finalCharacter,
          'finalCharacterDescription': _finalCharacterDescription,
          // Add the combined total score here
          'completionDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (error) {
      print("Error saving final character to highest result collection: $error");
    }


  await calculateCombinedTotalScore();

    String greetingText = 'Gratulation';

    final gsUrl1 = 'gs://personality-score.appspot.com/JingleKomprimiert.mp4';
    showFinalResultDialog(
        context, finalCharacter, finalCharacterDescription, greetingText,
        combinedTotalScore, gsUrl1);
  }



  /// Function to download the existing PDF
  Future<void> _downloadExistingPDF(String pdf_path) async {
    try {
      final ByteData pdfData = await rootBundle.load(pdf_path);
      final Uint8List pdfBytes = pdfData.buffer.asUint8List();

      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..download = pdf_path.split('/')[1]
        ..target = 'blank';
      anchor.click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error downloading existing PDF: $e');
    }
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

    // Controller für die E-Mail-Eingabe
    TextEditingController emailController = TextEditingController();
    TextEditingController nameController = TextEditingController(); // Added nameController

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
          content: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
              User? user = snapshot.data;

              return StatefulBuilder(
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
                                if ((user == null || user.displayName == null) && !isSubscribed) ...[
                                  Icon(Icons.lock, size: 50, color: Colors.grey),
                                  SizedBox(height: 10),
                                  SelectableText(
                                    "Ergebnis gesperrt. Melde dich an, um es zu sehen.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // Option 1: Direct login
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 32.0),
                                      backgroundColor: Color(0xFFCB9935),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                      ),
                                    ),
                                    onPressed: () {
                                      showSignInDialog(context); // Show the SignInDialog
                                    },
                                    child: Text(
                                      'Einloggen',
                                      style: TextStyle(fontFamily: 'Roboto'),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  // Option 2: Enter email address
                                  SelectableText(
                                    "Ohne Login. Gebe jetzt deinen Namen und deine Email an, um das Testergebnis freizuschalten.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Dein Vorname',
                                      border: OutlineInputBorder(),
                                      contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: 'E-Mail-Adresse eingeben',
                                      border: OutlineInputBorder(),
                                      contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 32.0),
                                      backgroundColor: Color(0xFFCB9935),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (emailController.text.isNotEmpty &&
                                          isValidEmail(emailController.text) &&
                                          nameController.text.isNotEmpty) {
                                        setState(() {
                                          isSubscribed = true;
                                          showContent =
                                          true; // Update to show subscribed content

                                        });

                                        try {
                                          // Newsletter subscription (call Cloud Function)
                                          final Uri cloudFunctionUrl = Uri.parse(
                                            'https://us-central1-personality-score.cloudfunctions.net/manage_newsletter',
                                          );

                                          final response = await http.get(
                                            cloudFunctionUrl.replace(
                                              queryParameters: {
                                                'email': emailController.text,
                                                'first_name':
                                                nameController.text,
                                              },
                                            ),
                                          );

                                          if (response.statusCode == 200) {
                                            print(
                                                'Newsletter erfolgreich abonniert!');
                                          } else {
                                            print(
                                                'Fehler beim Abonnieren des Newsletters: ${response.body}');
                                          }
                                        } catch (e) {
                                          // Netzwerk- oder Serverfehler
                                          print('Ein Fehler ist aufgetreten: $e');
                                        }
                                      } else {
                                        // Ungültige Eingaben
                                        print(
                                            'Bitte gebe eine gültige E-Mail-Adresse und deinen Vornamen ein.');
                                      }
                                    },
                                    child: Text(
                                      'Ergebnis ansehen',
                                      style: TextStyle(fontFamily: 'Roboto'),
                                    ),
                                  )
                                ] else ...[
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

                                  PDFListItem(
                                    pdfName:
                                    '$finalCharacter. Deine Beschreibung zum Herunterladen!',
                                    onDownload: () => _downloadExistingPDF(
                                        'auswertungen/$finalCharacter.pdf'),
                                  ),
                                ],
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


  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }
  Future<void> saveUserRating(double rating) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Get the highest result collection
        final highestResultCollection = await getHighestResultCollection();

        if (highestResultCollection != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(highestResultCollection)
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
  Future<void> saveCertificatePath(String userId, String path) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Get the highest result collection
        final highestResultCollection = await getHighestResultCollection();

        if (highestResultCollection != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(highestResultCollection)
              .doc('finalCharacter')
              .set({
            'certificatePath': path, // Save only the certificate path
          }, SetOptions(merge: true));

          print("Path saved to $highestResultCollection");
        } else {
          print("No result collections found to save user rating.");
        }
      } catch (e) {
        print("Error saving certificate path to Firestore: $e");
        throw Exception("Failed to save certificate path");
      }
    }
  }


  Future<String?> getCertificatePath(String userId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Get the highest result collection
        final highestResultCollection = await getHighestResultCollection();

        if (highestResultCollection != null) {
          // Retrieve the document
          final docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(highestResultCollection)
              .doc('finalCharacter')
              .get();

          // Check if the document exists and contains the 'certificatePath' field
          if (docSnapshot.exists && docSnapshot.data() != null) {
            final data = docSnapshot.data()!;
            if (data.containsKey('certificatePath')) {
              return data['certificatePath'] as String?;
            }
          }
        } else {
          print("No result collections found to retrieve the certificate path.");
        }
      } catch (e) {
        print("Error retrieving certificate path from Firestore: $e");
        throw Exception("Failed to retrieve certificate path");
      }
    }

    return null; // Return null if not found
  }


  Future<void> checkAndDownloadCertificate() async {
    User? user = _auth.currentUser;

    if (user != null) {
      final certificatePath = await getCertificatePath(user.uid);

      if (certificatePath != null) {
        // Certificate path found, proceed to download
        final certificateUrl =
        await FirebaseStorage.instance.ref(certificatePath).getDownloadURL();

        final anchor = html.AnchorElement(href: certificateUrl)
          ..download = 'Zertifikat_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf'
          ..target = '_blank';
        anchor.click();

        print("Certificate downloaded successfully.");
      } else {
        // No certificate found
        print("No certificate path found for this user.");
      }
    } else {
      print("No user logged in.");
    }
  }


  Future<int> getFirstScore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Get the highest result collection
        final highestResultCollection = await getHighestResultCollection();

        if (highestResultCollection != null) {
          // Fetch the highest result collection for the "Kompetenz" test
          final firstTestDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(highestResultCollection)
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


        // Get the highest result collection
    final highestResultCollection = await getHighestResultCollection();

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



  Future<void> calculateCombinedTotalScore() async {
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

      // Get the highest result collection
      final highestResultCollection = await getHighestResultCollection();

      if (highestResultCollection != null) {
        // Save combined score to Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(highestResultCollection)
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



}
