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

import 'detailed_result_ui.dart';
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

  /// Set zur Verfolgung der expandierten Ergebnisse (Index)
  Set<int> _expandedResults = <int>{};

  /// Helleres Beige, wie in der Mobile-Version
  static const Color middleColor = Color(0xFFF2EEE5);

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

      // Sortiere die Ergebnisse nach Datum aufsteigend (optional, falls gewünscht)
      results.sort((a, b) {
        DateTime dateA = a.completionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        DateTime dateB = b.completionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      });

      setState(() {
        validResults = results;
        // Standard: Zeige das jüngste Ergebnis (am Ende der sortierten Liste)
        selectedIndex = validResults.length - 1;
        _pageController = PageController(initialPage: selectedIndex);
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

  /// Beschreibung kürzen
  String _truncateDescription(String? description) {
    if (description == null) return '';
    final sentences = description.split('. ');
    if (sentences.length <= 4) {
      return description;
    } else {
      return sentences.take(4).join('. ') + '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

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
          children: [
          Center(
          child: Container(
          child: Align(
          alignment: Alignment.topRight,
            child: IconButton(
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
                            final userResult = validResults[index];
                            String completionDate =
                            _formatCompletionDate(userResult.completionDate);

                            // "Ergebnisnummer" (1-based)
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
                                              // Teilen-Icon mit kreisförmigem Hintergrund
                                              GestureDetector(
                                                onTap: () {
                                                  // Teilen-Funktion
                                                  String shareText =
                                                      '${userResult.combinedTotalScore} Prozent deines Potentials erreicht!\nDu bist ein ${userResult.finalCharacter}!\n\n${userResult.finalCharacterDescription}';
                                                  Share.share(shareText);
                                                },
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: middleColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      'assets/icons/share-svgrepo-com.svg',
                                                      width: 24,
                                                      height: 24,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              // Expand/Collapse-Icon mit kreisförmigem Hintergrund
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (_expandedResults
                                                        .contains(index)) {
                                                      _expandedResults
                                                          .remove(index);
                                                    } else {
                                                      _expandedResults
                                                          .add(index);
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: middleColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      _expandedResults
                                                          .contains(index)
                                                          ? 'assets/icons/shrink-svgrepo-com.svg'
                                                          : 'assets/icons/expand-svgrepo-com.svg',
                                                      width: 24,
                                                      height: 24,
                                                      color: Colors.black,
                                                    ),
                                                  ),
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
                                          // Beschreibungstext mit Expand/Collapse
                                          _expandedResults.contains(index)
                                              ? SelectableText(
                                            userResult
                                                .finalCharacterDescription ??
                                                '',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Roboto',
                                              fontSize: 16,
                                            ),
                                          )
                                              : SelectableText(
                                            _truncateDescription(
                                              userResult
                                                  .finalCharacterDescription,
                                            ),
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
                                  buildDetailedResultUI(userResult),
                                  SizedBox(height: 20),
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

  /// Angepasste AppBar (unbenutzt im aktuellen Code, da wir CustomAppBar nutzen)
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
