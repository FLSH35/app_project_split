// profile_desktop_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as logging;
import 'package:logging/logging.dart';

import 'signin_dialog.dart';
import 'home_screen/mobile_sidebar.dart';
import 'package:personality_score/models/result.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'custom_app_bar.dart';

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
  bool _isLoading = false;

  /// Hier speichern wir die Ergebnisse als Liste von [Result].
  List<Result> validResults = [];

  late PageController _pageController;
  int selectedIndex = 0; // Aktuelle Seite im PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Initialisieren der Datumsformatierung
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

  /// Holt alle Benutzerergebnisse von der Cloud Function
  Future<List<Result>> fetchUserResults(String uuid) async {
    final url = Uri.parse(
      'https://us-central1-personality-score.cloudfunctions.net/get_user_results?uuid=$uuid',
    );

    // Initialisieren des Loggers
    Logger logger = Logger('fetchUserResults');
    logger.info("Fetching data from Cloud Function for UUID: $uuid");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<Result> results =
        jsonData.map((item) => Result.fromJson(item)).toList();
        logger.info(
            "Successfully fetched and parsed ${results.length} results for UUID: $uuid");
        return results;
      } else {
        logger.severe(
            "Failed to fetch data. Status code: ${response.statusCode}");
        throw Exception('Failed to fetch data from server');
      }
    } catch (e) {
      logger.severe("Error fetching user results: $e");
      throw Exception('Error fetching user results: $e');
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
      final updatedAuthService =
      Provider.of<AuthService>(context, listen: false);
      if (updatedAuthService.user != null &&
          updatedAuthService.user!.displayName != null) {
        setState(() {
          widget.nameController.text = updatedAuthService.user!.displayName!;
        });
        await _fetchAndSetUserResults(updatedAuthService.user!.uid);
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
      await _fetchAndSetUserResults(authService.user!.uid);
    }
  }

  /// Holt die Ergebnisse und setzt sie in den State
  Future<void> _fetchAndSetUserResults(String uuid) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Result> results = await fetchUserResults(uuid);
      setState(() {
        validResults = results;
        selectedIndex = validResults.length - 1; // Start bei letztem Ergebnis
        _pageController = PageController(initialPage: 0);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Ergebnisse: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Kleiner Helper für deutsche Datumsanzeige
  String _formatCompletionDate(DateTime? date) {
    if (date == null) return '';
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
    return dateFormat.format(date.toLocal()) + ' Uhr';
  }

  /// Widget zur Anzeige detaillierter Scores (Lebensbereiche)
  Widget _buildDetailedResultUI(Result detailedResult) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Größeres Padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: LIFE_AREA_MAP_DART.entries.map((entry) {
          String lebensbereich = entry.key;
          String sumKey = entry.value[0];
          String countKey = entry.value[1];
          int sum = _getLebensbereichSum(detailedResult, sumKey);
          int count = _getLebensbereichCount(detailedResult, countKey);
          return _buildLebensbereichRow(lebensbereich, sum, count);
        }).toList(),
      ),
    );
  }

  /// Helper-Funktion, um die Summe eines Lebensbereichs abzurufen
  int _getLebensbereichSum(Result result, String sumKey) {
    switch (sumKey) {
      case 'SelbstwerterhoehungSum':
        return result.selbstwerterhoehungSum;
      case 'ZielsetzungSum':
        return result.zielsetzungSum;
      case 'WeiterbildungSum':
        return result.weiterbildungSum;
      case 'FinanzenSum':
        return result.finanzenSum;
      case 'KarriereSum':
        return result.karriereSum;
      case 'FitnessSum':
        return result.fitnessSum;
      case 'EnergieSum':
        return result.energieSum;
      case 'ProduktivitaetSum':
        return result.produktivitaetSum;
      case 'StressmanagementSum':
        return result.stressmanagementSum;
      case 'ResilienzSum':
        return result.resilienzSum;
      case 'InnerCoreInnerChangeSum':
        return result.innerCoreInnerChangeSum;
      case 'EmotionenSum':
        return result.emotionenSum;
      case 'GlaubenssaetzeSum':
        return result.glaubenssaetzeSum;
      case 'BindungBeziehungenSum':
        return result.bindungBeziehungenSum;
      case 'KommunikationSum':
        return result.kommunikationSum;
      case 'GemeinschaftSum':
        return result.gemeinschaftSum;
      case 'FamilieSum':
        return result.familieSum;
      case 'NetzwerkSum':
        return result.netzwerkSum;
      case 'DatingSum':
        return result.datingSum;
      case 'LebenssinnSum':
        return result.lebenssinnSum;
      case 'UmweltSum':
        return result.umweltSum;
      case 'SpiritualitaetSum':
        return result.spiritualitaetSum;
      case 'SpendenSum':
        return result.spendenSum;
      case 'LebensplanungSum':
        return result.lebensplanungSum;
      case 'SelbstfuersorgeSum':
        return result.selbstfuersorgeSum;
      case 'FreizeitSum':
        return result.freizeitSum;
      case 'SpassFreudeSum':
        return result.spassFreudeSum;
      case 'GesundheitSum':
        return result.gesundheitSum;
      default:
        return 0;
    }
  }

  /// Helper-Funktion, um die Count eines Lebensbereichs abzurufen
  int _getLebensbereichCount(Result result, String countKey) {
    switch (countKey) {
      case 'SelbstwerterhoehungCount':
        return result.selbstwerterhoehungCount;
      case 'ZielsetzungCount':
        return result.zielsetzungCount;
      case 'WeiterbildungCount':
        return result.weiterbildungCount;
      case 'FinanzenCount':
        return result.finanzenCount;
      case 'KarriereCount':
        return result.karriereCount;
      case 'FitnessCount':
        return result.fitnessCount;
      case 'EnergieCount':
        return result.energieCount;
      case 'ProduktivitaetCount':
        return result.produktivitaetCount;
      case 'StressmanagementCount':
        return result.stressmanagementCount;
      case 'ResilienzCount':
        return result.resilienzCount;
      case 'InnerCoreInnerChangeCount':
        return result.innerCoreInnerChangeCount;
      case 'EmotionenCount':
        return result.emotionenCount;
      case 'GlaubenssaetzeCount':
        return result.glaubenssaetzeCount;
      case 'BindungBeziehungenCount':
        return result.bindungBeziehungenCount;
      case 'KommunikationCount':
        return result.kommunikationCount;
      case 'GemeinschaftCount':
        return result.gemeinschaftCount;
      case 'FamilieCount':
        return result.familieCount;
      case 'NetzwerkCount':
        return result.netzwerkCount;
      case 'DatingCount':
        return result.datingCount;
      case 'LebenssinnCount':
        return result.lebenssinnCount;
      case 'UmweltCount':
        return result.umweltCount;
      case 'SpiritualitaetCount':
        return result.spiritualitaetCount;
      case 'SpendenCount':
        return result.spendenCount;
      case 'LebensplanungCount':
        return result.lebensplanungCount;
      case 'SelbstfuersorgeCount':
        return result.selbstfuersorgeCount;
      case 'FreizeitCount':
        return result.freizeitCount;
      case 'SpassFreudeCount':
        return result.spassFreudeCount;
      case 'GesundheitCount':
        return result.gesundheitCount;
      default:
        return 0;
    }
  }

  /// Helper widget to display Lebensbereich rows dynamically
  Widget _buildLebensbereichRow(String title, int sum, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text('$title: Sum = $sum')),
          Text('Count = $count'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    String uuid = user?.uid ?? "";

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: CustomAppBar(
        title: 'Personality Score',
      ),
      endDrawer: MobileSidebar(),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          constraints: BoxConstraints(maxWidth: 1200), // Begrenzung der Maximalbreite
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Name-Editing Widgets
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
                          onPageChanged: (index) {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          itemCount: validResults.length,
                          itemBuilder: (context, index) {
                            Result userResult = validResults[index];

                            String completionDate =
                            _formatCompletionDate(userResult.completionDate);

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
                                            duration:
                                            Duration(milliseconds: 300),
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
                                            fontSize: 18,
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
                                            duration:
                                            Duration(milliseconds: 300),
                                            curve: Curves.ease,
                                          );
                                        }
                                            : null,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  // Avatar
                                  CircleAvatar(
                                    radius: 100,
                                    backgroundImage: AssetImage(
                                      'assets/${userResult.finalCharacter}.webp',
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  SizedBox(height: 20),
                                  // Card für Short-Description mit Icons oben rechts
                                  Card(
                                    color: Color(0xFFF7F5EF),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // Icons oben rechts
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              // Entfernen der Expand-Icon, da detaillierte Ergebnisse bereits in einer einzigen Abfrage enthalten sind
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
                                          SelectableText(
                                            userResult.finalCharacterDescription ?? '',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Roboto',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // Detaillierte Ergebnisse (Lebensbereiche)
                                  _buildDetailedResultUI(userResult),
                                  SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      // Teilen- und Paywall-Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFFCB9935),
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                              ),
                            ),
                            onPressed: validResults.isNotEmpty
                                ? () {
                              // Aktuelles PageView-Item ermitteln
                              int sortedIndex =
                                  validResults.length - 1 - selectedIndex;
                              Result data = validResults[sortedIndex];
                              String shareText =
                                  '${data.combinedTotalScore} Prozent deines Potentials erreicht!\nDu bist ein ${data.finalCharacter}.\n\nBeschreibung: ${data.finalCharacterDescription}';
                              Share.share(shareText);
                            }
                                : null,
                            child: Text(
                              'Teilen',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontSize: 18),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.lock, color: Colors.white),
                            label: Text(
                              'Details freischalten',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Roboto'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
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
                      // Abmelden-Button
                      ElevatedButton(
                        onPressed: () async {
                          await authService.logout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 32.0),
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
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
                )
              else
                SelectableText(
                  'Kein Ergebnis gefunden.',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Roboto',
                    fontSize: 18,
                  ),
                ),
              SizedBox(height: 20),
            ],
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
}

/// Definieren Sie die LIFE_AREA_MAP_DART hier
const Map<String, List<String>> LIFE_AREA_MAP_DART = {
  // Hauptbereich 1: Selbstwerterhöhung
  "Selbstwerterhöhung": ["SelbstwerterhoehungSum", "SelbstwerterhoehungCount"],
  "Zielsetzung": ["ZielsetzungSum", "ZielsetzungCount"],
  "Weiterbildung": ["WeiterbildungSum", "WeiterbildungCount"],
  "Finanzen": ["FinanzenSum", "FinanzenCount"],
  "Karriere": ["KarriereSum", "KarriereCount"],
  "Fitness": ["FitnessSum", "FitnessCount"],

  // Hauptbereich 2: Energie
  "Energie": ["EnergieSum", "EnergieCount"],
  "Produktivität": ["ProduktivitaetSum", "ProduktivitaetCount"],
  "Stressmanagement": ["StressmanagementSum", "StressmanagementCount"],
  "Resilienz": ["ResilienzSum", "ResilienzCount"],

  // Hauptbereich 3: Inner Core, Inner Change
  "Inner Core, Inner Change": [
    "InnerCoreInnerChangeSum",
    "InnerCoreInnerChangeCount"
  ],
  "Emotionen": ["EmotionenSum", "EmotionenCount"],
  "Glaubenssätze": ["GlaubenssaetzeSum", "GlaubenssaetzeCount"],

  // Hauptbereich 4: Bindung & Beziehungen
  "Bindung & Beziehungen": ["BindungBeziehungenSum", "BindungBeziehungenCount"],
  "Kommunikation": ["KommunikationSum", "KommunikationCount"],
  "Gemeinschaft": ["GemeinschaftSum", "GemeinschaftCount"],
  "Familie": ["FamilieSum", "FamilieCount"],
  "Netzwerk": ["NetzwerkSum", "NetzwerkCount"],
  "Dating": ["DatingSum", "DatingCount"],

  // Hauptbereich 5: Lebenssinn
  "Lebenssinn": ["LebenssinnSum", "LebenssinnCount"],
  "Umwelt": ["UmweltSum", "UmweltCount"],
  "Spiritualität": ["SpiritualitaetSum", "SpiritualitaetCount"],
  "Spenden": ["SpendenSum", "SpendenCount"],
  "Lebensplanung": ["LebensplanungSum", "LebensplanungCount"],
  "Selbstfürsorge": ["SelbstfuersorgeSum", "SelbstfuersorgeCount"],
  "Freizeit": ["FreizeitSum", "FreizeitCount"],
  "Spaß & Freude im Leben": ["SpassFreudeSum", "SpassFreudeCount"],
  "Gesundheit": ["GesundheitSum", "GesundheitCount"],
};
