import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'custom_app_bar.dart'; // Import the custom AppBar
import 'package:personality_score/screens/signin_dialog.dart'; // Import the SignInDialog

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
  int selectedIndex = 0; // To keep track of the current page
  int initialPage = 10000; // For infinite scrolling

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: initialPage);
    _initialize();
  }

  Future<void> fetchFinalCharacters() async {
    _isLoading = true;
    try {
      final user = Provider
          .of<AuthService>(context, listen: false)
          .user;
      if (user != null) {
        final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

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
                data['combinedTotalScore'] is num) {
              // Check if 'completionDate' exists
              if (data['completionDate'] != null) {
                // Add the collection name to the data
                data['collectionName'] = collectionName;
                tempResults.add(data);
              }
            }
          }
        }

        // Sort tempResults by 'completionDate' descending
        tempResults.sort((a, b) {
          Timestamp dateA = a['completionDate'];
          Timestamp dateB = b['completionDate'];
          return dateB.compareTo(dateA); // Sort in descending order
        });

        setState(() {
          validResults = tempResults; // Update the state
          selectedIndex = initialPage % validResults.length;
        });
      }
    } catch (error) {
      print("Error loading Profile Data: $error");
    }
    _isLoading = false;
  }

  Future<void> _initialize() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.user == null || authService.user?.displayName == null) {
      // Show sign-in dialog after the first frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog(
          context: context,
          barrierDismissible: false, // Prevents dismissing by tapping outside
          builder: (context) =>
              SignInDialog(
                emailController: TextEditingController(),
                passwordController: TextEditingController(),
                allowAnonymous: false, // Disallow anonymous sign-in
              ),
        );

        // Re-check authentication state after dialog closes
        final updatedAuthService = Provider.of<AuthService>(
            context, listen: false);
        if (updatedAuthService.user != null &&
            updatedAuthService.user!.displayName != null) {
          setState(() {
            widget.nameController.text = updatedAuthService.user!.displayName!;
          });
          // Now fetch the characters
          fetchFinalCharacters();
        } else {
          // Handle case where sign-in failed or was canceled
        }
      });
    } else {
      // User is authenticated and has a displayName
      setState(() {
        widget.nameController.text = authService.user!.displayName!;
      });
      // Fetch the characters
      fetchFinalCharacters();
    }
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
          // Added to prevent overflow in smaller screens
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
                        labelText: 'Display Name',
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
              // Display the loading indicator when data is loading
                Center(child: CircularProgressIndicator())
              else
                if (validResults.isNotEmpty)
                // Display the results if data is available
                  Column(
                    children: [
                      SizedBox(
                        height: 700, // Adjust height as needed
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              selectedIndex = index % validResults.length;
                              isExpanded =
                              false; // Reset expansion when page changes
                            });
                          },
                          // Set itemCount to null for infinite scrolling
                          itemBuilder: (context, index) {
                            int adjustedIndex = index % validResults.length;
                            Map<String,
                                dynamic> data = validResults[adjustedIndex];

                            String completionDate = '';
                            if (data['completionDate'] != null) {
                              Timestamp timestamp = data['completionDate'];
                              DateTime date = timestamp.toDate();
                              completionDate =
                              '${date.day}.${date.month}.${date.year}';
                            }

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Title with left and right arrows
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_left),
                                      onPressed: () {
                                        _pageController.previousPage(
                                            duration: Duration(
                                                milliseconds: 300),
                                            curve: Curves.ease);
                                      },
                                    ),
                                    Text(
                                        'Test abgeschlossen am: $completionDate',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto')),
                                    IconButton(
                                      icon: Icon(Icons.arrow_right),
                                      onPressed: () {
                                        _pageController.nextPage(
                                            duration: Duration(
                                                milliseconds: 300),
                                            curve: Curves.ease);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                CircleAvatar(
                                  radius: 100,
                                  backgroundImage: AssetImage(
                                      'assets/${data['finalCharacter']}.webp'),
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
                                                color: Colors.black,
                                                fontFamily: 'Roboto')),
                                        SizedBox(height: 10),
                                        isExpanded
                                            ? Container(
                                          height:
                                          300,
                                          // Set a fixed height for scrolling
                                          child: SingleChildScrollView(
                                            child: SelectableText(
                                              data[
                                              'finalCharacterDescription'] ??
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
                                            padding:
                                            const EdgeInsets.all(20.0),
                                            child: SingleChildScrollView(
                                              child: SelectableText(
                                                data['finalCharacterDescription'] !=
                                                    null
                                                    ? data[
                                                'finalCharacterDescription']
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
                                        // "Lese mehr" or "Lese weniger" button
                                        TextButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 32.0),
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
                                            isExpanded
                                                ? 'Lese weniger'
                                                : 'Lese mehr',
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
                      // You can add indicators or navigation buttons here if desired
                    ],
                  )
                else
                // Display a message if no data is found
                  SelectableText(
                    'Kein Ergebnis gefunden.',
                    style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                  ),
              SizedBox(height: 20),
              // Share button
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
                      Map<String, dynamic> data =
                      validResults[selectedIndex];
                      String shareText =
                          '${data['combinedTotalScore']} Prozent deines Potentials erreicht!\nDu bist ein ${data['finalCharacter']}.\n\nBeschreibung: ${data['finalCharacterDescription']}';
                      Share.share(shareText);
                    }
                        : null, // Disable button if data is missing
                    child: Text('Teilen',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Roboto')),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await authService.logout(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
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
