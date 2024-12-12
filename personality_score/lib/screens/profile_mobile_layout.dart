// profile_mobile_layout.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'signin_dialog.dart';
import 'mobile_sidebar.dart';

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
  bool isExpanded = false;
  bool _isLoading = false;

  List<Map<String, dynamic>> validResults = [];
  late PageController _pageController;
  int selectedIndex = 0; // Aktuelle Seite

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _pageController = PageController(initialPage: 0);
    fetchFinalCharacters();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchFinalCharacters() async {
    setState(() {
      _isLoading = true;
    });

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

        // Umkehren, damit das älteste Ergebnis an Index 0 steht
        validResults = tempResults.reversed.toList();

        setState(() {
          _isLoading = false;
          // Wir wollen beim neuesten Ergebnis starten, das sich jetzt am Ende der Liste befindet
          selectedIndex = validResults.length - 1;
        });

        // Nach dem Bauen der Widgets auf die letzte Seite springen:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (validResults.isNotEmpty) {
            _pageController.jumpToPage(validResults.length - 1);
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error loading profile data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Profildaten.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    final berlin = tz.getLocation('Europe/Berlin');
    tz.TZDateTime dateInGermany = tz.TZDateTime.from(date, berlin);
    DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
    return dateFormat.format(dateInGermany) + ' Uhr';
  }

  String _truncateDescription(String description) {
    List<String> sentences = description.split('. ');
    if (sentences.length <= 4) {
      return description;
    } else {
      return sentences.take(4).join('. ') + '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: _buildAppBar(context),
      endDrawer: MobileSidebar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
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
                    : Row(
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
                  Column(
                    children: [
                      SizedBox(
                        height: 550,
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
                              completionDate = _formatTimestamp(timestamp);
                            }

                            // Ergebnisnummer: Da das älteste bei 0 steht, ist index 0 = Ergebnis 1.
                            int resultNumber = index + 1;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_left),
                                      onPressed: index > 0
                                          ? () {
                                        _pageController.previousPage(
                                            duration: Duration(milliseconds: 300),
                                            curve: Curves.ease);
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
                                            curve: Curves.ease);
                                      }
                                          : null,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: AssetImage('assets/${data['finalCharacter']}.webp'),
                                  backgroundColor: Colors.transparent,
                                ),
                                SizedBox(height: 10),

                                Card(
                                  color: Color(0xFFF7F5EF),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        SelectableText(
                                          '${data['combinedTotalScore']} Prozent deines Potentials erreicht!\nDu bist ein ${data['finalCharacter']}!',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        isExpanded
                                            ? Container(
                                          constraints: BoxConstraints(
                                            maxHeight: 240,
                                          ),
                                          child: SingleChildScrollView(
                                            child: SelectableText(
                                              data['finalCharacterDescription'] ??
                                                  'Beschreibung nicht verfügbar.',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Roboto',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )
                                            : Container(
                                          constraints: BoxConstraints(
                                            maxHeight: 100,
                                          ),
                                          child: SingleChildScrollView(
                                            child: SelectableText(
                                              data['finalCharacterDescription'] != null
                                                  ? _truncateDescription(
                                                  data['finalCharacterDescription'])
                                                  : 'Beschreibung nicht verfügbar.',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Roboto',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                              backgroundColor: isExpanded
                                                  ? Colors.black
                                                  : Color(0xFFCB9935),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
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
                                                fontSize: 14,
                                              ),
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
                    ],
                  )
                else
                  SelectableText(
                    'Kein Ergebnis gefunden.',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFFCB9935),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      child: Text(
                        'Teilen',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    await authService.logout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
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
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: SelectableText(
        'PROFIL',
        style: TextStyle(color: Colors.black),
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
