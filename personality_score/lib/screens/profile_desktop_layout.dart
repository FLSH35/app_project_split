import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart'; // Import für Datum und Zeitformatierung
import 'custom_app_bar.dart'; // Import der benutzerdefinierten AppBar
import 'package:personality_score/screens/signin_dialog.dart'; // Import des Anmelde-Dialogs
import 'package:intl/date_symbol_data_local.dart';

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
  int selectedIndex = 0; // Aktuelle Seite

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initialize();
  }

  Future<void> fetchFinalCharacters() async {
    _isLoading = true;
    try {
      final user = Provider.of<AuthService>(context, listen: false).user;
      if (user != null) {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        List<String> resultCollectionNames = ['results'];

        for (int i = 1; i <= 100; i++) {
          resultCollectionNames.add('results_$i');
        }

        List<Map<String, dynamic>> tempResults = [];

        for (String collectionName in resultCollectionNames) {
          final collectionRef = userDocRef.collection(collectionName);
          final docSnapshot = await collectionRef.doc('finalCharacter').get();

          if (docSnapshot.exists) {
            var data = docSnapshot.data() as Map<String, dynamic>?;
            if (data != null &&
                data['combinedTotalScore'] != null &&
                data['combinedTotalScore'] is num &&
                data['completionDate'] != null) {
              data['collectionName'] = collectionName;
              tempResults.add(data);
            }
          }
        }

        // Sortieren nach Abschlussdatum absteigend (neueste zuerst)
        tempResults.sort((a, b) {
          Timestamp dateA = a['completionDate'];
          Timestamp dateB = b['completionDate'];
          return dateB.compareTo(dateA);
        });

        // Umkehren, damit ältestes Ergebnis an Index 0 steht
        validResults = tempResults.reversed.toList();

        setState(() {
          selectedIndex = 0; // Wir starten bei Seite 0
        });
      }
    } catch (error) {
      print("Fehler beim Laden der Profildaten: $error");
    }
    _isLoading = false;
  }

  Future<void> _initialize() async {
    await initializeDateFormatting('de_DE', null); // Lokalisierungsdaten initialisieren
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
          fetchFinalCharacters();
        } else {
          // Handle fehlgeschlagene Anmeldung
        }
      });
    } else {
      setState(() {
        widget.nameController.text = authService.user!.displayName!;
      });
      fetchFinalCharacters();
    }
  }

  int _calculateGermanOffset(DateTime date) {
    DateTime dstStart = _lastSundayOfMonth(date.year, 3);
    dstStart = DateTime(date.year, 3, dstStart.day, 2);
    DateTime dstEnd = _lastSundayOfMonth(date.year, 10);
    dstEnd = DateTime(date.year, 10, dstEnd.day, 3);

    if (date.isAfter(dstStart) && date.isBefore(dstEnd)) {
      return 2; // Sommerzeit (MESZ)
    } else {
      return 1; // Winterzeit (MEZ)
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
                        onPageChanged: (index) {
                          setState(() {
                            selectedIndex = index;
                            isExpanded = false;
                          });
                        },
                        itemCount: validResults.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data = validResults[index];

                          String completionDate = '';
                          if (data['completionDate'] != null) {
                            Timestamp timestamp = data['completionDate'];
                            DateTime date = timestamp.toDate();

                            int offset = _calculateGermanOffset(date);
                            DateTime dateInGermany = date.add(Duration(hours: offset));
                            DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
                            completionDate = dateFormat.format(dateInGermany) + ' Uhr';
                          }

                          int resultNumber = index + 1;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_left),
                                    onPressed: () {
                                      if (index > 0) {
                                        _pageController.previousPage(
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
                                      if (index < validResults.length - 1) {
                                        _pageController.nextPage(
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
                                        height: 300,
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
                  'Kein Ergebnis gefunden.',
                  style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                ),
              SizedBox(height: 20),
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
                      Map<String, dynamic> data = validResults[selectedIndex];
                      String shareText =
                          '${data['combinedTotalScore']} Prozent deines Potentials erreicht!\nDu bist ein ${data['finalCharacter']}.\n\nBeschreibung: ${data['finalCharacterDescription']}';
                      Share.share(shareText);
                    }
                        : null,
                    child: Text('Teilen',
                        style:
                        TextStyle(color: Colors.white, fontFamily: 'Roboto')),
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
