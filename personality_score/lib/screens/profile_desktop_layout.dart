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
  bool isExpanded = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  List<Map<String, dynamic>> validResults = [];
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
          List<Map<String, dynamic>> tempResults = data.map((item) {
            return {
              "combinedTotalScore": item['CombinedTotalScore'],
              "finalCharacter": item['FinalCharacter'],
              "finalCharacterDescription": item['FinalCharacterDescription'],
              "completionDate": item['CompletionDate'],
              "collectionName": item['ResultsX'], // Entspricht 'collectionName'
            };
          }).toList();

          // Sort the results by completionDate ascending (ältestes zuerst)
          tempResults.sort((a, b) {
            DateTime dateA = DateTime.parse(a['completionDate']);
            DateTime dateB = DateTime.parse(b['completionDate']);
            return dateA.compareTo(dateB); // Ascending order
          });

          validResults = tempResults;

          setState(() {
            selectedIndex = validResults.length -1; // Start bei letztem Ergebnis
            _pageController = PageController(initialPage: 0);
          });

          logging.log("Successfully fetched and processed ${validResults.length} results.");
        } else {
          logging.log("Failed to fetch data from Cloud Function. Status Code: ${response.statusCode}");
        }
      }
    } catch (error) {
      logging.log("Error fetching data from Cloud Function: $error");
      print("Fehler beim Laden der Profildaten: $error");
    }

    setState(() {
      _isLoading = false;
    });
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                Column(
                  children: [
                    SizedBox(
                      height: 700,
                      child: PageView.builder(
                        controller: _pageController,
                        reverse: true, // Neueste zuerst anzeigen
                        onPageChanged: (index) {
                          setState(() {
                            selectedIndex = validResults.length - 1 - index;
                            isExpanded = false;
                          });
                        },
                        itemCount: validResults.length,
                        itemBuilder: (context, index) {
                          // Index umdrehen, da reverse = true
                          int sortedIndex = validResults.length - 1 - index;
                          Map<String, dynamic> data = validResults[sortedIndex];

                          String completionDate = '';
                          if (data['completionDate'] != null && data['completionDate'] != '') {
                            DateTime date = DateTime.parse(data['completionDate']);
                            int offset = _calculateGermanOffset(date);
                            DateTime dateInGermany = date.add(Duration(hours: offset));
                            DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
                            completionDate = dateFormat.format(dateInGermany) + ' Uhr';
                          }

                          int resultNumber = sortedIndex + 1; // Älteste = 1

                          return Column(
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
                                AssetImage('assets/${data['finalCharacter']}.webp'),
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
                                        '${data['combinedTotalScore']} Prozent deines Potentials erreicht!\nDu bist ein ${data['finalCharacter']}!',
                                        style: TextStyle(
                                            color: Colors.black, fontFamily: 'Roboto'),
                                      ),
                                      SizedBox(height: 10),
                                      isExpanded
                                          ? Container(
                                        height: 250,
                                        child: SingleChildScrollView(
                                          child: SelectableText(
                                            data['finalCharacterDescription'] ??
                                                'Beschreibung nicht verfügbar.',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Roboto',
                                                fontSize: 18),
                                          ),
                                        ),
                                      )
                                          : Container(
                                        height: 250,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: SingleChildScrollView(
                                            child: SelectableText(
                                              data['finalCharacterDescription'] != null
                                                  ? data['finalCharacterDescription']
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
                                      ),
                                      TextButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                                          backgroundColor: isExpanded
                                              ? Colors.black
                                              : Color(0xFFCB9935),
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
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Roboto',
                                            fontSize: 18,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
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
                      Map<String, dynamic> data = validResults[sortedIndex];
                      String shareText =
                          '${data['combinedTotalScore']} Prozent deines Potentials erreicht!\nDu bist ein ${data['finalCharacter']}.\n\nBeschreibung: ${data['finalCharacterDescription']}';
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
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto'
                      ),
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
