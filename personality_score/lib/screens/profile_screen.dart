import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'custom_app_bar.dart'; // Import the custom AppBar

class ProfileScreen extends StatelessWidget {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.photoURL ?? 'https://via.placeholder.com/150'), // Placeholder image
            ),
            SizedBox(height: 20),
            Text(
              user.displayName ?? 'Anonymous User',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Roboto'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('results')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var results = snapshot.data!.docs;
                  for (var result in results) {
                    if (result.id == 'finalCharacter') {
                      return Container(
                        width: double.infinity,
                        child: Card(
                          color: Color(0xFFF7F5EF),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0), // Adjust padding if needed
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Final Character',
                                  style: TextStyle(color: Colors.black, fontFamily: 'Roboto'), // Adjust text color if needed
                                ),
                                SizedBox(height: 10),
                                Image.asset(
                                  'assets/${result['finalCharacter']}',
                                  width: 100, height: 100,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  result['finalCharacterDescription'],
                                  style: TextStyle(color: Colors.black, fontFamily: 'Roboto'), // Adjust text color if needed
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return Center(
                    child: Text(
                      'No final character found.',
                      style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
