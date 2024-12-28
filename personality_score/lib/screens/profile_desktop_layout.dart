import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'custom_app_bar.dart';
import 'package:personality_score/screens/signin_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as logging;

// -------------------- Result Class --------------------
class Result {
  final String userUUID;
  final String resultsX;
  final double combinedTotalScore;
  final DateTime completionDate;
  final String finalCharacter;
  final String finalCharacterDescription;

  // Lebensbereiche
  final int selbstwerterhoehung;
  final int zielsetzung;
  final int weiterbildung;
  final int finanzen;
  final int karriere;
  final int fitness;
  final int energie;
  final int produktivitaet;
  final int stressmanagement;
  final int resilienz;
  final int innerCoreInnerChange;
  final int emotionen;
  final int glaubenssaetze;
  final int bindungBeziehungen;
  final int kommunikation;
  final int gemeinschaft;
  final int familie;
  final int netzwerk;
  final int dating;
  final int lebenssinn;
  final int umwelt;
  final int spiritualitaet;
  final int spenden;
  final int lebensplanung;
  final int selbstfuersorge;
  final int freizeit;
  final int spassFreude;
  final int gesundheit;

  Result({
    required this.userUUID,
    required this.resultsX,
    required this.combinedTotalScore,
    required this.completionDate,
    required this.finalCharacter,
    required this.finalCharacterDescription,
    required this.selbstwerterhoehung,
    required this.zielsetzung,
    required this.weiterbildung,
    required this.finanzen,
    required this.karriere,
    required this.fitness,
    required this.energie,
    required this.produktivitaet,
    required this.stressmanagement,
    required this.resilienz,
    required this.innerCoreInnerChange,
    required this.emotionen,
    required this.glaubenssaetze,
    required this.bindungBeziehungen,
    required this.kommunikation,
    required this.gemeinschaft,
    required this.familie,
    required this.netzwerk,
    required this.dating,
    required this.lebenssinn,
    required this.umwelt,
    required this.spiritualitaet,
    required this.spenden,
    required this.lebensplanung,
    required this.selbstfuersorge,
    required this.freizeit,
    required this.spassFreude,
    required this.gesundheit,
  });

  /// Erstellt eine `Result`-Instanz aus einer JSON-Karte
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      userUUID: json['User-UUID'] as String,
      resultsX: json['ResultsX'] as String,
      combinedTotalScore: (json['CombinedTotalScore'] as num).toDouble(),
      completionDate: DateTime.parse(cleanDateString(json['CompletionDate'] as String)),
      finalCharacter: json['FinalCharacter'] as String,
      finalCharacterDescription: json['FinalCharacterDescription'] as String,
      selbstwerterhoehung: json['Selbstwerterhoehung'] ?? 0,
      zielsetzung: json['Zielsetzung'] ?? 0,
      weiterbildung: json['Weiterbildung'] ?? 0,
      finanzen: json['Finanzen'] ?? 0,
      karriere: json['Karriere'] ?? 0,
      fitness: json['Fitness'] ?? 0,
      energie: json['Energie'] ?? 0,
      produktivitaet: json['Produktivitaet'] ?? 0,
      stressmanagement: json['Stressmanagement'] ?? 0,
      resilienz: json['Resilienz'] ?? 0,
      innerCoreInnerChange: json['InnerCoreInnerChange'] ?? 0,
      emotionen: json['Emotionen'] ?? 0,
      glaubenssaetze: json['Glaubenssaetze'] ?? 0,
      bindungBeziehungen: json['BindungBeziehungen'] ?? 0,
      kommunikation: json['Kommunikation'] ?? 0,
      gemeinschaft: json['Gemeinschaft'] ?? 0,
      familie: json['Familie'] ?? 0,
      netzwerk: json['Netzwerk'] ?? 0,
      dating: json['Dating'] ?? 0,
      lebenssinn: json['Lebenssinn'] ?? 0,
      umwelt: json['Umwelt'] ?? 0,
      spiritualitaet: json['Spiritualitaet'] ?? 0,
      spenden: json['Spenden'] ?? 0,
      lebensplanung: json['Lebensplanung'] ?? 0,
      selbstfuersorge: json['Selbstfuersorge'] ?? 0,
      freizeit: json['Freizeit'] ?? 0,
      spassFreude: json['SpassFreude'] ?? 0,
      gesundheit: json['Gesundheit'] ?? 0,
    );
  }

  /// Konvertiert eine `Result`-Instanz in eine JSON-Karte
  Map<String, dynamic> toJson() {
    return {
      'User-UUID': userUUID,
      'ResultsX': resultsX,
      'CombinedTotalScore': combinedTotalScore,
      'CompletionDate': completionDate.toIso8601String(),
      'FinalCharacter': finalCharacter,
      'FinalCharacterDescription': finalCharacterDescription,
      'Selbstwerterhoehung': selbstwerterhoehung,
      'Zielsetzung': zielsetzung,
      'Weiterbildung': weiterbildung,
      'Finanzen': finanzen,
      'Karriere': karriere,
      'Fitness': fitness,
      'Energie': energie,
      'Produktivitaet': produktivitaet,
      'Stressmanagement': stressmanagement,
      'Resilienz': resilienz,
      'InnerCoreInnerChange': innerCoreInnerChange,
      'Emotionen': emotionen,
      'Glaubenssaetze': glaubenssaetze,
      'BindungBeziehungen': bindungBeziehungen,
      'Kommunikation': kommunikation,
      'Gemeinschaft': gemeinschaft,
      'Familie': familie,
      'Netzwerk': netzwerk,
      'Dating': dating,
      'Lebenssinn': lebenssinn,
      'Umwelt': umwelt,
      'Spiritualitaet': spiritualitaet,
      'Spenden': spenden,
      'Lebensplanung': lebensplanung,
      'Selbstfuersorge': selbstfuersorge,
      'Freizeit': freizeit,
      'SpassFreude': spassFreude,
      'Gesundheit': gesundheit,
    };
  }
}

String cleanDateString(String dateStr) {
  // Entfernt die zusätzlichen Millisekunden und das "+" vor "Z"
  return dateStr.replaceAllMapped(
    RegExp(r'(\.\d{6})?\+00:00Z$'),
        (match) => 'Z',
  );
}

// -------------------- UserResult Class --------------------
class UserResult {
  final String combinedTotalScore;
  final String finalCharacter;
  final String finalCharacterDescription;
  final String completionDate;
  final String collectionName;

  bool isExpanded;
  Result? detailedResult;
  bool isLoadingDetails;
  String? errorLoadingDetails;

  UserResult({
    required this.combinedTotalScore,
    required this.finalCharacter,
    required this.finalCharacterDescription,
    required this.completionDate,
    required this.collectionName,
    this.isExpanded = false,
    this.detailedResult,
    this.isLoadingDetails = false,
    this.errorLoadingDetails,
  });
}

class ProfileDesktopLayout extends StatefulWidget {
  final TextEditingController nameController;
  final bool isEditingName;
  final VoidCallback onEditName;
  final VoidCallback onSaveName;

  ProfileDesktopLayout({
    required this.nameController,
    required this.isEditingName,
    required this.onEditName,
    required this.onSaveName,
  });

  @override
  _ProfileDesktopLayoutState createState() => _ProfileDesktopLayoutState();
}

class _ProfileDesktopLayoutState extends State<ProfileDesktopLayout> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  List<UserResult> validResults = [];
  late PageController _pageController;
  int selectedIndex = 0; // Current page index

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initialize();
  }

  Future<void> fetchFinalCharactersFromCloudFunction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthService>(context, listen: false).user;
      if (user != null) {
        final uuid = user.uid;
        final url = Uri.parse(
            'https://us-central1-personality-score.cloudfunctions.net/get_user_results?uuid=$uuid');

        logging.log("Fetching data from Cloud Function for UUID: $uuid");

        final response = await http.get(url);

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);

          // Validate and map the data
          List<UserResult> tempResults = data.map((item) {
            return UserResult(
              combinedTotalScore: item['CombinedTotalScore'].toString(),
              finalCharacter: item['FinalCharacter'],
              finalCharacterDescription: item['FinalCharacterDescription'],
              completionDate: item['CompletionDate'],
              collectionName: item['ResultsX'],
            );
          }).toList();

          // Sort the results by completionDate ascending (ältestes zuerst)
          tempResults.sort((a, b) {
            DateTime dateA = DateTime.parse(a.completionDate);
            DateTime dateB = DateTime.parse(b.completionDate);
            return dateA.compareTo(dateB); // Ascending order
          });

          setState(() {
            validResults = tempResults;
            selectedIndex = validResults.length - 1; // Start bei letztem Ergebnis
            _pageController = PageController(initialPage: 0);
          });

          logging.log("Successfully fetched and processed ${validResults.length} results.");
        } else {
          logging.log("Failed to fetch data from Cloud Function. Status Code: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Laden der Ergebnisse. Status Code: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (error) {
      logging.log("Error fetching data from Cloud Function: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler beim Laden der Profildaten: $error"),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<Result> fetchResultSummary(String userUUID, String resultsX) async {
    // Construct the URI with query parameters
    final uri = Uri.https(
      'us-central1-personality-score.cloudfunctions.net',
      '/get_result_summary',
      {
        'User-UUID': userUUID,
        'ResultsX': resultsX,
      },
    );

    try {
      // Make the HTTP GET request
      final response = await http.get(uri);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Create and return a Result object from JSON
        return Result.fromJson(jsonResponse);
      } else {
        // Handle non-200 responses
        throw Exception(
            'Failed to load result summary. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      throw Exception('Error fetching result summary: $e');
    }
  }

  Future<void> _initialize() async {
    await initializeDateFormatting('de_DE', null); // Localization
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.user == null || authService.user?.displayName == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SignInDialog(
            emailController: TextEditingController(),
            passwordController: TextEditingController(),
            allowAnonymous: false,
          ),
        );

        final updatedAuthService = Provider.of<AuthService>(context, listen: false);
        if (updatedAuthService.user != null && updatedAuthService.user!.displayName != null) {
          setState(() {
            widget.nameController.text = updatedAuthService.user!.displayName!;
          });
          await fetchFinalCharactersFromCloudFunction();
        } else {
          // Handle failed login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anmeldung fehlgeschlagen.'),
            ),
          );
        }
      });
    } else {
      setState(() {
        widget.nameController.text = authService.user!.displayName!;
      });
      await fetchFinalCharactersFromCloudFunction();
    }
  }

  int _calculateGermanOffset(DateTime date) {
    DateTime dstStart = _lastSundayOfMonth(date.year, 3);
    dstStart = DateTime(date.year, 3, dstStart.day, 2);
    DateTime dstEnd = _lastSundayOfMonth(date.year, 10);
    dstEnd = DateTime(date.year, 10, dstEnd.day, 3);

    if (date.isAfter(dstStart) && date.isBefore(dstEnd)) {
      return 2; // Daylight Saving Time (CEST)
    } else {
      return 1; // Standard Time (CET)
    }
  }

  DateTime _lastSundayOfMonth(int year, int month) {
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);
    int weekday = lastDayOfMonth.weekday;
    int lastSunday = lastDayOfMonth.day - ((weekday) % 7);
    return DateTime(year, month, lastSunday);
  }

  // Helper widget to display detailed result data
  Widget _buildDetailedResultUI(Result detailedResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lebensbereiche Scores:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        _buildLebensbereichRow('Selbstwerterhöhung', detailedResult.selbstwerterhoehung),
        _buildLebensbereichRow('Zielsetzung', detailedResult.zielsetzung),
        _buildLebensbereichRow('Weiterbildung', detailedResult.weiterbildung),
        _buildLebensbereichRow('Finanzen', detailedResult.finanzen),
        _buildLebensbereichRow('Karriere', detailedResult.karriere),
        _buildLebensbereichRow('Fitness', detailedResult.fitness),
        _buildLebensbereichRow('Energie', detailedResult.energie),
        _buildLebensbereichRow('Produktivität', detailedResult.produktivitaet),
        _buildLebensbereichRow('Stressmanagement', detailedResult.stressmanagement),
        _buildLebensbereichRow('Resilienz', detailedResult.resilienz),
        _buildLebensbereichRow('Inner Core Inner Change', detailedResult.innerCoreInnerChange),
        _buildLebensbereichRow('Emotionen', detailedResult.emotionen),
        _buildLebensbereichRow('Glaubenssätze', detailedResult.glaubenssaetze),
        _buildLebensbereichRow('Bindung & Beziehungen', detailedResult.bindungBeziehungen),
        _buildLebensbereichRow('Kommunikation', detailedResult.kommunikation),
        _buildLebensbereichRow('Gemeinschaft', detailedResult.gemeinschaft),
        _buildLebensbereichRow('Familie', detailedResult.familie),
        _buildLebensbereichRow('Netzwerk', detailedResult.netzwerk),
        _buildLebensbereichRow('Dating', detailedResult.dating),
        _buildLebensbereichRow('Lebenssinn', detailedResult.lebenssinn),
        _buildLebensbereichRow('Umwelt', detailedResult.umwelt),
        _buildLebensbereichRow('Spiritualität', detailedResult.spiritualitaet),
        _buildLebensbereichRow('Spenden', detailedResult.spenden),
        _buildLebensbereichRow('Lebensplanung', detailedResult.lebensplanung),
        _buildLebensbereichRow('Selbstfürsorge', detailedResult.selbstfuersorge),
        _buildLebensbereichRow('Freizeit', detailedResult.freizeit),
        _buildLebensbereichRow('Spaß & Freude', detailedResult.spassFreude),
        _buildLebensbereichRow('Gesundheit', detailedResult.gesundheit),
      ],
    );
  }

  // Helper function to build Lebensbereich rows
  Widget _buildLebensbereichRow(String title, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(child: Text('$title:')),
          Text('$score'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = Provider.of<AuthService>(context, listen: false).user;
    String uuid = "";
    if (user != null) {
      uuid = user.uid;
    }

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: CustomAppBar(
        title: 'Personality Score',
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          constraints: BoxConstraints(maxWidth: 1200), // Optional: Begrenzung der Maximalbreite
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Name Editing Widgets
              widget.isEditingName
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: widget.nameController,
                      decoration: InputDecoration(
                        labelText: 'Anzeigename',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: widget.onSaveName,
                  ),
                ],
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    widget.nameController.text,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto'),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: widget.onEditName,
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (validResults.isNotEmpty)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          reverse: true, // Neueste zuerst anzeigen
                          onPageChanged: (index) {
                            setState(() {
                              selectedIndex = validResults.length - 1 - index;
                            });
                          },
                          itemCount: validResults.length,
                          itemBuilder: (context, index) {
                            // Index umdrehen, da reverse = true
                            int sortedIndex = validResults.length - 1 - index;
                            UserResult userResult = validResults[sortedIndex];

                            String completionDate = '';
                            if (userResult.completionDate.isNotEmpty) {
                              DateTime date = DateTime.parse(userResult.completionDate);
                              int offset = _calculateGermanOffset(date);
                              DateTime dateInGermany = date.add(Duration(hours: offset));
                              DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
                              completionDate = dateFormat.format(dateInGermany) + ' Uhr';
                            }

                            int resultNumber = sortedIndex + 1; // Älteste = 1

                            return SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_left),
                                        onPressed: () {
                                          if (index < validResults.length - 1) {
                                            _pageController.nextPage(
                                                duration: Duration(milliseconds: 300),
                                                curve: Curves.ease);
                                          }
                                        },
                                      ),
                                      Text(
                                        'Ergebnis $resultNumber: abgeschlossen am $completionDate',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto'),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.arrow_right),
                                        onPressed: () {
                                          if (index > 0) {
                                            _pageController.previousPage(
                                                duration: Duration(milliseconds: 300),
                                                curve: Curves.ease);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  CircleAvatar(
                                    radius: 100,
                                    backgroundImage:
                                    AssetImage('assets/${userResult.finalCharacter}.webp'),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  SizedBox(height: 20),
                                  Card(
                                    color: Color(0xFFF7F5EF),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SelectableText(
                                            '${userResult.combinedTotalScore} Prozent deines Potentials erreicht!\nDu bist ein ${userResult.finalCharacter}!',
                                            style: TextStyle(
                                                color: Colors.black, fontFamily: 'Roboto'),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 10),
                                          // Beschreibung ausklappen
                                          userResult.isExpanded
                                              ? Container(
                                            child: Column(
                                              children: [
                                                SelectableText(
                                                  userResult.finalCharacterDescription.isNotEmpty
                                                      ? userResult.finalCharacterDescription
                                                      : 'Beschreibung nicht verfügbar.',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'Roboto',
                                                      fontSize: 18),
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            ),
                                          )
                                              : Container(
                                            child: Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: SelectableText(
                                                userResult.finalCharacterDescription.isNotEmpty
                                                    ? userResult.finalCharacterDescription
                                                    .split('. ')
                                                    .take(4)
                                                    .join('. ') +
                                                    '...'
                                                    : 'Beschreibung nicht verfügbar.',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Roboto',
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(horizontal: 32.0),
                                              backgroundColor: userResult.isExpanded
                                                  ? Colors.black
                                                  : Color(0xFFCB9935),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(8.0)),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                userResult.isExpanded = !userResult.isExpanded;
                                              });
                                            },
                                            child: Text(
                                              userResult.isExpanded ? 'Lese weniger' : 'Lese mehr',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Roboto',
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          // ------------------- Mehr Details Button -------------------
                                          if (userResult.isExpanded)
                                            Column(
                                              children: [
                                                userResult.detailedResult != null
                                                    ? _buildDetailedResultUI(userResult.detailedResult!)
                                                    : userResult.isLoadingDetails
                                                    ? CircularProgressIndicator()
                                                    : userResult.errorLoadingDetails != null
                                                    ? Text(
                                                  'Fehler: ${userResult.errorLoadingDetails}',
                                                  style:
                                                  TextStyle(color: Colors.red),
                                                )
                                                    : ElevatedButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      userResult.isLoadingDetails = true;
                                                      userResult.errorLoadingDetails = null;
                                                    });
                                                    try {
                                                      // Fetch detailed result
                                                      Result detailedResult =
                                                      await fetchResultSummary(
                                                        uuid,
                                                        userResult.collectionName,
                                                      );
                                                      if (!mounted) return;
                                                      setState(() {
                                                        userResult.detailedResult =
                                                            detailedResult;
                                                      });
                                                    } catch (e) {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        userResult.errorLoadingDetails =
                                                            e.toString();
                                                      });
                                                    } finally {
                                                      if (mounted) {
                                                        setState(() {
                                                          userResult.isLoadingDetails =
                                                          false;
                                                        });
                                                      }
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                    Color(0xFFCB9935),
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8.0)),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Mehr Details laden',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Roboto',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          // ------------------- End Mehr Details Button -------------------
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                )
              else
                SelectableText(
                  'Kein Ergebnis gefunden. $uuid',
                  style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                ),
              SizedBox(height: 20),

              // ------------------------------------
              //  TEILEN-BUTTON
              // ------------------------------------
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFCB9935),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                    onPressed: validResults.isNotEmpty
                        ? () {
                      // Aktuelles PageView-Item ermitteln
                      int sortedIndex = validResults.length - 1 - selectedIndex;
                      UserResult data = validResults[sortedIndex];
                      String shareText =
                          '${data.combinedTotalScore} Prozent deines Potentials erreicht!\nDu bist ein ${data.finalCharacter}.\n\nBeschreibung: ${data.finalCharacterDescription}';
                      Share.share(shareText);
                    }
                        : null,
                    child: Text(
                      'Teilen',
                      style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                    ),
                  ),

                  // NEU: UPSELLING-/PAYWALL-BUTTON
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.lock, color: Colors.white), // Schloss-Icon
                    label: Text(
                      'Details freischalten',
                      style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Hier Paywall-/Upselling-Logik einfügen
                      // 1. Paywall zeigen oder Payment-Flow starten
                      // 2. Bei Erfolg -> zusätzliche Inhalte/Analyse freischalten
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Upselling/Paywall geöffnet.'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  await authService.logout(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                child: Text(
                  'Abmelden',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
