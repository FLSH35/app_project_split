import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'custom_app_bar.dart'; // Import the custom AppBar
import 'package:personality_score/models/newsletter_service.dart';
import 'package:personality_score/auth/auth_service.dart';

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

  final NewsletterService _newsletterService = NewsletterService();
  bool isSubscribedToNewsletter = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeNewsletterStatus();
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

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Profile',
        ),
        body: Center(
          child: SelectableText(
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
              radius: 100,
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
            if (widget.finalCharacterData != null)
              Card(
                color: Color(0xFFF7F5EF),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectableText(
                            '${widget.finalCharacterData!['combinedTotalScore']} Prozent deines Potentials erreicht!\nDu bist ein ${widget.finalCharacterData?['finalCharacter']}!',
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto')),
                        SizedBox(height: 10),
                        isExpanded
                            ? Container(
                          height: 300, // Set a fixed height for scrolling
                          child: SingleChildScrollView(
                            child: SelectableText(
                                widget.finalCharacterData![
                                'finalCharacterDescription'],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontSize: 18)),
                          ),
                        )
                            : Container(
                          height: 250,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                widget.finalCharacterData![
                                'finalCharacterDescription']
                                    .split('. ')
                                    .take(4)
                                    .join('. ') +
                                    '...',
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
              ))
            else
              SelectableText(
                'No final character found.',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
            SizedBox(height: 20),
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
    ),),
                  onPressed: () {
                    String shareText = '${widget.finalCharacterData!['combinedTotalScore']} Prozent deines Potentials erreicht!\nDu bist ein ${widget.finalCharacterData!['finalCharacter']}.\n\nBeschreibung: ${widget.finalCharacterData!['finalCharacterDescription']}';
                    Share.share(shareText);
                  },
                  child: Text('Teilen',
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'Roboto')),
                ),

              ],
            ),
            Container(width: 400,
            child: SwitchListTile(
              title: Text(
                'Newsletter Anmeldung',
                style: TextStyle(
                    fontSize: 18, fontFamily: 'Roboto'),
              ),
              value: isSubscribedToNewsletter,
              onChanged: (value) => _toggleNewsletterSubscription(value),
              activeColor: Color(0xFFCB9935),
            )),
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
    );
  }
}
