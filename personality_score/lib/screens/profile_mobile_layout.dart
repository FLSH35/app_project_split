import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:developer' as logging;
import 'signin_dialog.dart';
import 'home_screen/mobile_sidebar.dart';

import 'package:personality_score/models/result.dart';

class ProfileMobileLayout extends StatefulWidget {
  final TextEditingController nameController;
  final bool isEditingName;
  final VoidCallback onEditName;
  final VoidCallback onSaveName;

  ProfileMobileLayout({
    required this.nameController,
    required this.isEditingName,
    required this.onEditName,
    required this.onSaveName,
  });

  @override
  _ProfileMobileLayoutState createState() => _ProfileMobileLayoutState();
}

class _ProfileMobileLayoutState extends State<ProfileMobileLayout> {
  bool _isLoading = false;

  /// Hier speichern wir die Ergebnisse als Liste von [UserResult].
  List<UserResult> validResults = [];

  late PageController _pageController;
  int selectedIndex = 0; // Aktuelle Seite im PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // (Optional) Datumsformatierung initialisieren
    initializeDateFormatting('de_DE', null);

    // Sobald der Screen geladen ist, rufen wir die Cloud Function ab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Ähnlich wie im Desktop-Code:
  /// Holt die Liste aller Ergebnisse aus der Cloud Function get_user_results?uuid=...
  Future<void> fetchFinalCharactersFromCloudFunction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthService>(context, listen: false).user;
      if (user != null) {
        final uuid = user.uid;
        final url = Uri.parse(
          'https://us-central1-personality-score.cloudfunctions.net/get_user_results?uuid=$uuid',
        );

        logging.log("Fetching data from Cloud Function (Mobile) for UUID: $uuid");

        final response = await http.get(url);

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);

          // Zu UserResult parsen
          List<UserResult> tempResults = data.map((item) {
            return UserResult(
              combinedTotalScore: item['CombinedTotalScore'].toString(),
              finalCharacter: item['FinalCharacter'],
              finalCharacterDescription: item['FinalCharacterDescription'],
              completionDate: item['CompletionDate'],
              collectionName: item['ResultsX'],
            );
          }).toList();

          // Sortieren nach completionDate, ältestes zuerst
          tempResults.sort((a, b) {
            DateTime dateA = DateTime.parse(a.completionDate);
            DateTime dateB = DateTime.parse(b.completionDate);
            return dateA.compareTo(dateB);
          });

          setState(() {
            validResults = tempResults;
            // Wir starten (wie gewünscht) direkt beim neusten Ergebnis.
            selectedIndex = validResults.length - 1;
            // PageController neu aufsetzen
            _pageController = PageController(initialPage: selectedIndex);
          });

          logging.log(
              "Successfully fetched and processed ${validResults.length} results (Mobile).");
        } else {
          logging.log(
              "Failed to fetch data (Mobile). Status Code: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Fehler beim Laden der Ergebnisse. Status Code: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (error) {
      logging.log("Error fetching data (Mobile): $error");
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

  /// Holt für ein bestimmtes Result-CollectionName die Detaildaten (Scores, Lebensbereiche usw.)
  Future<Result> fetchResultSummary(String userUUID, String resultsX) async {
    final uri = Uri.https(
      'us-central1-personality-score.cloudfunctions.net',
      '/get_result_summary',
      {
        'User-UUID': userUUID,
        'ResultsX': resultsX,
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Result.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to load result summary. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching result summary: $e');
    }
  }

  /// Überprüft, ob der User eingeloggt ist, fragt ggf. nach Login und lädt dann die Ergebnisse
  Future<void> _initialize() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.user == null || authService.user?.displayName == null) {
      // Falls nicht eingeloggt, zeige SignInDialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SignInDialog(
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          allowAnonymous: false,
          nextRoute: '/profile',
        ),
      );

      // Nach dem Dialog nochmal prüfen, ob jetzt eingeloggt
      final updatedAuthService = Provider.of<AuthService>(context, listen: false);
      if (updatedAuthService.user != null &&
          updatedAuthService.user!.displayName != null) {
        setState(() {
          widget.nameController.text = updatedAuthService.user!.displayName!;
        });
        await fetchFinalCharactersFromCloudFunction();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anmeldung fehlgeschlagen.')),
        );
      }
    } else {
      // Direkt laden, wenn bereits eingeloggt
      setState(() {
        widget.nameController.text = authService.user!.displayName!;
      });
      await fetchFinalCharactersFromCloudFunction();
    }
  }

  /// Kleiner Helper für deutsche Datumsanzeige
  String _formatCompletionDate(String isoString) {
    if (isoString.isEmpty) return '';
    DateTime date = DateTime.parse(isoString);
    // Du kannst hier gern noch Winter-/Sommerzeit-Abfragen machen
    // oder `DateFormat('dd.MM.yyyy HH:mm', 'de_DE')` verwenden.
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
    return dateFormat.format(date) + ' Uhr';
  }

  /// Widget zur Anzeige detaillierter Scores (Lebensbereiche)
  Widget _buildDetailedResultUI(Result detailedResult) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Größeres Padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      ),
    );
  }

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

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: _buildAppBar(context),
      endDrawer: MobileSidebar(),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Erhöhtes Padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Name-Editing
                widget.isEditingName
                    ? Row(
                  children: [
                    Expanded(
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
                    : Column(
                  children: [
                    Center(
                      child: Container(
                        child: Align(
                          alignment: Alignment.topRight,
                          child:  IconButton(
                            icon: Icon(Icons.logout, color: Colors.black),
                            onPressed: () async {
                              await authService.logout(context);
                            },
                            alignment: Alignment.topRight,
                            tooltip: 'Abmelden',
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SelectableText(
                          widget.nameController.text,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: widget.onEditName,
                        ),

                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                else if (validResults.isNotEmpty)
                  SizedBox(
                    height: 700, // ausreichend Platz fürs Scrollen
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      itemCount: validResults.length,
                      itemBuilder: (context, index) {
                        UserResult userResult = validResults[index];

                        String completionDate =
                        _formatCompletionDate(userResult.completionDate);

                        // Da 0 das älteste ist, ist Index + 1 die "Ergebnisnummer"
                        int resultNumber = index + 1;

                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              // Navigations-Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_left),
                                    onPressed: index > 0
                                        ? () {
                                      _pageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    }
                                        : null,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Ergebnis $resultNumber: abgeschlossen am $completionDate',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_right),
                                    onPressed: index < validResults.length - 1
                                        ? () {
                                      _pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    }
                                        : null,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              // Avatar
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: AssetImage(
                                  'assets/${userResult.finalCharacter}.webp',
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              SizedBox(height: 10),

                              // Card für Short-Description mit Icons oben rechts
                              Card(
                                color: Color(0xFFF7F5EF),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0), // Erhöhtes Padding
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Icons oben rechts
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // Teilen-Funktion
                                              String shareText =
                                                  '${userResult.combinedTotalScore} Prozent deines Potentials erreicht!\nDu bist ein ${userResult.finalCharacter}!\n\n${userResult.finalCharacterDescription}';
                                              Share.share(shareText);
                                            },
                                            child: SvgPicture.asset(
                                              'assets/icons/share-svgrepo-com.svg',
                                              width: 24,
                                              height: 24,
                                              color: Colors.black, // Passe die Farbe an
                                            ),
                                          ),
                                          SizedBox(width: 16), // Abstand zwischen den Icons
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                userResult.isExpanded = !userResult.isExpanded;
                                              });
                                            },
                                            child: SvgPicture.asset(
                                              'assets/icons/arrow-expand-svgrepo-com.svg',
                                              width: 24,
                                              height: 24,
                                              color: Colors.black, // Passe die Farbe an
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      SelectableText(
                                        '${userResult.combinedTotalScore} Prozent deines Potentials erreicht!\nDu bist ein ${userResult.finalCharacter}!',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Roboto',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),

                                      // Langer/kurzer Beschreibungstext
                                      userResult.isExpanded
                                          ? Container(
                                        constraints: BoxConstraints(
                                          maxHeight: 300,
                                        ),
                                        child: SingleChildScrollView(
                                          child: SelectableText(
                                            userResult.finalCharacterDescription,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Roboto',
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                          : Container(
                                        // Falls du hier den Text kürzen möchtest,
                                        // kannst du das wie gehabt mit einer Hilfsfunktion tun.
                                        child: SelectableText(
                                          _truncateDescription(
                                            userResult.finalCharacterDescription,
                                          ),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),

                                      // Entfernt den bisherigen "Lese mehr" Button
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),

                                userResult.detailedResult != null
                                    ? _buildDetailedResultUI(
                                    userResult.detailedResult!)
                                    : userResult.isLoadingDetails
                                    ? CircularProgressIndicator()
                                    : userResult.errorLoadingDetails != null
                                    ? Text(
                                  'Fehler: ${userResult.errorLoadingDetails}',
                                  style: TextStyle(
                                      color: Colors.red),
                                )
                                    : Container(),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else
                  SelectableText(
                    'Kein Ergebnis gefunden.',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),

                SizedBox(height: 20),

                // Entfernt die bisherigen "Teilen" und "Details freischalten" Buttons

                // Weitere Inhalte können hier hinzugefügt werden

              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Angepasste AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Flexible(
          child: GestureDetector(
            onTap: () async {
              const url = 'https://ifyouchange.com/';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: Image.asset(
              'assets/Logo-IYC-gross.png',
              height: 50,
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFF7F5EF),
      iconTheme: IconThemeData(color: Colors.black),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  /// Beispiel-Hilfsfunktion, um die Beschreibung zu kürzen (falls du das möchtest)
  String _truncateDescription(String description) {
    final sentences = description.split('. ');
    if (sentences.length <= 4) {
      return description;
    } else {
      return sentences.take(4).join('. ') + '...';
    }
  }
}
