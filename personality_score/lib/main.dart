import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:personality_score/screens/questionnaire_screen.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart'; // Ensure you have this file generated
import 'package:personality_score/screens/profile_screen.dart';
import 'package:personality_score/models/questionaire_model.dart';
import 'package:personality_score/screens/personality_type_screen.dart'; // Import the new screen

import 'package:package_info_plus/package_info_plus.dart';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> checkForUpdates() async {
  // Fetch the current app version
  final packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  // Fetch the latest version from Firestore
  final snapshot = await FirebaseFirestore.instance
      .collection('appConfig')
      .doc('latestVersion')
      .get();

  if (snapshot.exists) {
    String latestVersion = snapshot['version'];

    if (latestVersion != currentVersion) {
      // Reload the page if the versions don't match
      html.window.location.reload();
    }
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await checkForUpdates();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService(context)),
        ChangeNotifierProvider(create: (_) => QuestionnaireModel()),
      ],
      child: MaterialApp(
        title: 'Personality Score',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/home',
        routes: {
          '/': (context) => HomeScreen(),
          '/home': (context) => HomeScreen(),
          '/questionnaire': (context) => QuestionnaireScreen(),
          '/profile': (context) => ProfileScreen(),
          '/personality_types': (context) => PersonalityTypesPage(),
          '/impressum': (context) => ImpressumPage(),
          '/datenschutz': (context) => DatenschutzPage(),
        },
      ),
    );
  }
}
class ImpressumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Impressum'),
        backgroundColor: Color(0xFFCB9935), // Same as the app's gold color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          'This is the Impressum page where the legal information goes...',
          style: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
    );
  }
}

class DatenschutzPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datenschutz'),
        backgroundColor: Color(0xFFCB9935), // Same as the app's gold color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          'This is the Datenschutz page where privacy policies go...',
          style: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
    );
  }
}