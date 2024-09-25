import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'profile_desktop_layout.dart'; // Import the desktop layout
import 'mobile_sidebar.dart'; // Import the mobile sidebar
import 'package:personality_score/auth/auth_service.dart';
import 'package:share_plus/share_plus.dart'; // Import share package

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? finalCharacterData;
  bool _isEditingName = false;
  TextEditingController _nameController = TextEditingController();

  bool isExpanded = false; // Add this line for expansion state

  @override
  void initState() {
    super.initState();
    fetchFinalCharacter();
  }

  Future<void> fetchFinalCharacter() async {
    final user = Provider.of<AuthService>(context, listen: false).user;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('results')
          .doc('finalCharacter')
          .get();

      if (snapshot.exists) {
        setState(() {
          finalCharacterData = snapshot.data() as Map<String, dynamic>?;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(context), // Mobile layout
      desktop: ProfileDesktopLayout(
        nameController: _nameController,
        finalCharacterData: finalCharacterData,
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

  // Mobile Layout
  Widget _buildMobileLayout(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    if (user == null) {
      return Scaffold(
        appBar: _buildAppBar(context), // Add AppBar for mobile with menu button
        endDrawer: MobileSidebar(), // Use the mobile sidebar
        body: Center(
          child: Text(
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
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                      'assets/${finalCharacterData?['finalCharacter'] ?? ''}.webp'),
                  backgroundColor: Colors.transparent,
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
                    Text(
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Du bist ein ${finalCharacterData!['finalCharacter']}',
                            style: TextStyle(
                                color: Colors.black, fontFamily: 'Roboto'),
                          ),
                          SizedBox(height: 10),
                          Image.asset(
                            'assets/${finalCharacterData!['finalCharacter']}.webp',
                            width: 100,
                            height: 100,
                          ),
                          SizedBox(height: 10),
                          isExpanded
                              ? Column(
                            children: [
                              Text(
                                finalCharacterData![
                                'finalCharacterDescription'] ??
                                    'No description available.',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontSize: 18),
                              ),
                              SizedBox(height: 10),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFFCB9935),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isExpanded = false;
                                  });
                                },
                                child: Text(
                                  'Lese weniger',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Roboto'),
                                ),
                              ),
                            ],
                          )
                              : Column(
                            children: [
                              Text(
                                finalCharacterData![
                                'finalCharacterDescription']
                                    ?.split('. ')
                                    .take(2)
                                    .join('. ') +
                                    '...',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontSize: 18),
                              ),
                              SizedBox(height: 10),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFFCB9935),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isExpanded = true;
                                  });
                                },
                                child: Text(
                                  'Lese mehr',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Roboto'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    'No final character found.',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'Roboto', fontSize: 18),
                  ),
                SizedBox(height: 20),
                // Finish and Share buttons
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Abschließen',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Roboto')),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () {
                        String shareText =
                            'Du bist ein ${finalCharacterData!['finalCharacter']}.\n\nBeschreibung: ${finalCharacterData!['finalCharacterDescription']}';
                        Share.share(shareText);
                      },
                      child: Text('Teilen',
                          style: TextStyle(
                              color: Color(0xFFCB9935), fontFamily: 'Roboto')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mobile AppBar with a menu button to open the sidebar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Questionnaire'),
      backgroundColor: Colors.grey[300], // Light grey for mobile
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
