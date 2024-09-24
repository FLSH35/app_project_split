// profile_desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'custom_app_bar.dart'; // Import the custom AppBar

class ProfileDesktopLayout extends StatelessWidget {
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
            style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Roboto'),
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
              radius: 250,
              backgroundImage: AssetImage('assets/${finalCharacterData?['finalCharacter'] ?? ''}'),
              backgroundColor: Colors.transparent, // Optional: set to transparent if no image available
            ),
            SizedBox(height: 20),
            isEditingName
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: onSaveName,
                ),
              ],
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nameController.text, // Use the updated name controller text
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto'),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEditName,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Final Character',
                        style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                      ),
                      SizedBox(height: 10),
                      Image.asset(
                        'assets/${finalCharacterData!['finalCharacter']}',
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 10),
                      Text(
                        finalCharacterData!['finalCharacterDescription'] ?? 'No description available.',
                        style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                'No final character found.',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
          ],
        ),
      ),
    );
  }
}
