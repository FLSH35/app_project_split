import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'custom_app_bar.dart'; // Import the custom AppBar

class ProfileDesktopLayout extends StatefulWidget {
  final TextEditingController nameController;
  final Map<String, dynamic>? finalCharacterData;
  final bool isEditingName;
  final VoidCallback onEditName;
  final VoidCallback onSaveName;

  ProfileDesktopLayout({
    required this.nameController,
    required this.finalCharacterData,
    required this.isEditingName,
    required this.onEditName,
    required this.onSaveName,
  });

  @override
  _ProfileDesktopLayoutState createState() => _ProfileDesktopLayoutState();
}

class _ProfileDesktopLayoutState extends State<ProfileDesktopLayout> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Profile',
        ),
        body: Center(
          child: Text(
            'Please sign in to see your profile.',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontFamily: 'Roboto'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: CustomAppBar(
        title: 'Personality Score',
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 125,
              backgroundImage: AssetImage(
                  'assets/${widget.finalCharacterData?['finalCharacter']}.webp'),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 20),
            widget.isEditingName
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
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
                Text(
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
            if (widget.finalCharacterData != null)
              Card(
                color: Color(0xFFF7F5EF),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Du bist ein ${widget.finalCharacterData?['finalCharacter']}',
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto')),
                        SizedBox(height: 10),
                        isExpanded
                            ? Container(
                          height: 350, // Set a fixed height for scrolling
                          child: SingleChildScrollView(
                            child: Text(
                                widget.finalCharacterData![
                                'finalCharacterDescription'],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontSize: 18)),
                          ),
                        )
                            : Container(
                          height: 350,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  widget.finalCharacterData![
                                  'finalCharacterDescription']
                                      .split('. ')
                                      .take(7)
                                      .join('. ') +
                                      '...',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // "Lese mehr" or "Lese weniger" button
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 32.0),
                            backgroundColor: isExpanded
                                ? Color(0xFFCB9935)
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
              Text(
                'No final character found.',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
            SizedBox(height: 20), // Add spacing before buttons
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
                        'Du bist ein ${widget.finalCharacterData!['finalCharacter']}.\n\nBeschreibung: ${widget.finalCharacterData!['finalCharacterDescription']}';
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
    );
  }
}
