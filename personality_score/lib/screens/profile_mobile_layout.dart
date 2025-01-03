// profile_mobile_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'detailed_result_ui.dart';
import 'signin_dialog.dart';
import 'home_screen/mobile_sidebar.dart';
import 'package:personality_score/models/result.dart';
import 'package:personality_score/auth/auth_service.dart';

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

  /// Hier speichern wir die Ergebnisse als Liste von [Result].
  List<Result> validResults = [];
  static const Color middleColor = Color(0xFFF2EEE5);

  late PageController _pageController;
  int selectedIndex = 0; // Aktuelle Seite im PageView

  /// Set zur Verfolgung der expandierten Ergebnisse (Index)
  Set<int> _expandedResults = Set<int>();

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
        // Sortieren nach completionDate, ältestes zuerst
        results.sort((a, b) {
          DateTime dateA = a.completionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          DateTime dateB = b.completionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateA.compareTo(dateB);
        });

        validResults = results;
        selectedIndex = validResults.length - 1;
        // PageController neu aufsetzen
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



  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: _buildAppBar(context),
      endDrawer: MobileSidebar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name-Editing Section
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
                // Logout Button Aligned to Top-Right
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.logout, color: Colors.black),
                    onPressed: () async {
                      await authService.logout(context);
                    },
                    tooltip: 'Abmelden',
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

            // Loading Indicator or Results
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (validResults.isNotEmpty)
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
                          // Navigation Buttons
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
                                    duration:
                                    Duration(milliseconds: 300),
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

                          // Card for Short Description with Icons
                          Card(
                            color: Color(0xFFF7F5EF),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Icons at the Top Right
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      // Share Icon with Circular Background
                                      GestureDetector(
                                        onTap: () {
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
                                      // Expand/Collapse Icon with Circular Background
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

                                  // Description with Expand/Collapse
                                  _expandedResults.contains(index)
                                      ? Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        userResult
                                            .finalCharacterDescription ??
                                            '',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                      : SelectableText(
                                    _truncateDescription(
                                      userResult
                                          .finalCharacterDescription,
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                          // Detailed Results (Lebensbereiche)
                          buildDetailedResultUI(userResult),
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

            // Weitere Inhalte können hier hinzugefügt werden
          ],
        ),
      ),
    );
  }


  /// Angepasste AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar( title: Image.asset(
      'assets/Logo-IYC-gross.png', height: 50,
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
  String _truncateDescription(String? description) {
    if (description == null) return '';
    final sentences = description.split('. ');
    if (sentences.length <= 4) {
      return description;
    } else {
      return sentences.take(4).join('. ') + '...';
    }
  }
}
