import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../models/newsletter_service.dart';
import 'profile_desktop_layout.dart'; // Import the desktop layout
import 'mobile_sidebar.dart'; // Import the mobile sidebar
import 'package:personality_score/auth/auth_service.dart';
import 'package:share_plus/share_plus.dart'; // Import share package

import 'package:firebase_auth/firebase_auth.dart';
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? finalCharacterData;
  bool _isEditingName = false;
  TextEditingController _nameController = TextEditingController();
  final NewsletterService _newsletterService = NewsletterService();
  bool isSubscribedToNewsletter = false;
  bool isExpanded = false; // Add this line for expansion state

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchFinalCharacter();
    _initializeNewsletterStatus();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context), // Mobile layout
      desktop: ProfileDesktopLayout(
        nameController: _nameController,
        isEditingName: _isEditingName,
        onEditName: () {
          setState(() {
            _isEditingName = true;
          });
        },
        onSaveName: updateUserName,
      ), // Desktop layout
    );
  }


  Future<String> getHighestResultCollection() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      String userId = user.uid;
      final userDocRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

      int maxCollectionNumber = 0;
      int currentCollectionNumber = 1;
      int consecutiveMisses = 0;
      int maxConsecutiveMisses = 5; // Adjust this threshold as needed

      while (consecutiveMisses < maxConsecutiveMisses) {
        final collectionName = 'results_$currentCollectionNumber';
        final collectionRef = userDocRef.collection(collectionName);

        // Check if 'finalCharacter' document exists in this collection
        final docRef = collectionRef.doc('finalCharacter');
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          maxCollectionNumber = currentCollectionNumber;
          consecutiveMisses = 0; // Reset consecutive misses since we found a valid collection
        } else {
          consecutiveMisses++;
        }

        currentCollectionNumber++;
      }

      if (maxCollectionNumber == 0) {
        return 'results_1'; // Default to 'results_1' if no valid collections are found
      }
      return 'results_$maxCollectionNumber';
    } catch (e) {
      print('Error fetching highest result collection: $e');
      return 'results_1'; // Return default in case of error
    }
  }

  Future<void> fetchFinalCharacter() async {
    try {
      String highestResultCollection = await getHighestResultCollection();

      final user = Provider.of<AuthService>(context, listen: false).user;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(highestResultCollection)
            .doc('finalCharacter')
            .get();

        if (snapshot.exists) {
          setState(() {
            finalCharacterData = snapshot.data() as Map<String, dynamic>?;
          });
        } else {
          setState(() {
            finalCharacterData = null;
          });
        }
      }
    } catch (error) {
      print("Error loading Profile Data: $error");
      setState(() {
        finalCharacterData = null;
      });
    }
  }

  // ... [Other methods remain the same]

  Widget _buildMobileLayout(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    if (user == null) {
      return Scaffold(
        appBar: _buildAppBar(context), // Add AppBar for mobile with menu button
        endDrawer: MobileSidebar(), // Use the mobile sidebar
        body: Center(
          child: SelectableText(
            'Please sign in to see your profile.',
            style: TextStyle(
                fontSize: 18, color: Colors.black, fontFamily: 'Roboto'),
          ),
        ),
      );
    }

    // Initialize the name controller with the current display name
    if (!_isEditingName) {
      _nameController.text = user.displayName ?? '';
    }

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: _buildAppBar(context), // Add AppBar for mobile with menu button
      endDrawer: MobileSidebar(), // Use the mobile sidebar
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Add padding for better layout
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                finalCharacterData != null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                      'assets/${finalCharacterData!['finalCharacter']}.webp'),
                  backgroundColor: Colors.transparent,
                )
                    : CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, size: 50), // Placeholder image
                ),
                SizedBox(height: 20),
                _isEditingName
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: updateUserName,
                    ),
                  ],
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableText(
                      _nameController.text,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Roboto'),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          _isEditingName = true;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (finalCharacterData != null)
                  Card(
                    color: Color(0xFFF7F5EF),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SelectableText(
                                '${finalCharacterData!['combinedTotalScore']} Prozent deines Potentials erreicht!\nDu bist ein ${finalCharacterData!['finalCharacter']}!',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto')),
                            SizedBox(height: 10),

                            // "Lese mehr" or "Lese weniger" button
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SelectableText(
                    'Kein Ergebnis gefunden.',
                    style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                  ),
                SizedBox(height: 20), // Add spacing before buttons
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
                      onPressed: finalCharacterData != null
                          ? () {
                        String shareText =
                            '${finalCharacterData!['combinedTotalScore']} Prozent deines Potentials erreicht!\nDu bist ein ${finalCharacterData!['finalCharacter']}.\n\nBeschreibung: ${finalCharacterData!['finalCharacterDescription']}';
                        Share.share(shareText);
                      }
                          : null, // Disable button if no data
                      child: Text('Teilen',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Roboto')),
                    ),
                  ],
                ),
                // Newsletter subscription switch
                Container(
                    width: 400,
                    child: SwitchListTile(
                      title: Text(
                        'Newsletter Anmeldung',
                        style:
                        TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                      ),
                      value: isSubscribedToNewsletter,
                      onChanged: (value) =>
                          _toggleNewsletterSubscription(value),
                      activeColor: Color(0xFFCB9935),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateUserName() async {
    final user = Provider.of<AuthService>(context, listen: false).user;

    if (user != null && _nameController.text.isNotEmpty) {
      // Update Firebase Authentication profile
      await user.updateDisplayName(_nameController.text);
      await user.reload();

      // Update Firestore user document
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'displayName': _nameController.text,
      });

      setState(() {
        _isEditingName = false;
      });

      // Refresh the name displayed in the UI
      _nameController.text = user.displayName ?? '';
    }
  }
  Future<void> _initializeNewsletterStatus() async {
    try {
      final status = await _newsletterService.fetchNewsletterStatus();
      setState(() {
        isSubscribedToNewsletter = status;
      });
    } catch (e) {
      print('Error fetching newsletter status: $e');
    }
  }

  Future<void> _toggleNewsletterSubscription(bool value) async {
    try {
      await _newsletterService.updateNewsletterStatus(value);
      setState(() {
        isSubscribedToNewsletter = value;
      });
    } catch (e) {
      print('Error updating newsletter subscription: $e');
    }
  }

  // Mobile AppBar with a menu button to open the sidebar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('PROFIL'),
      backgroundColor: Color(0xFFF7F5EF), // Light grey for mobile
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu), // Menu icon to open the sidebar
            onPressed: () {
              Scaffold.of(context)
                  .openEndDrawer(); // Open the sidebar for mobile
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false, // Remove back button for mobile
    );
  }
}
