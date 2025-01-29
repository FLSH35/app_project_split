import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:personality_score/screens/home_screen/home_screen.dart';
import 'package:personality_score/screens/questionnaire_screen.dart';
import 'package:personality_score/services/impressum.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'firebase_options.dart'; // Ensure you have this file generated
import 'package:personality_score/screens/profile_screen.dart';
import 'package:personality_score/models/questionaire_model.dart';
import 'package:personality_score/screens/personality_type_screen.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        // IMPORTANT: Do NOT specify initialRoute here.
        // Flutter will check the browser URL and use the matching route.

        // 1) Named Routes map
        routes: {
          // The default path: shows HomeScreen when user navigates to '/'
          '/': (context) => HomeScreen(),
          // You can also map /home to HomeScreen if desired
          '/home': (context) => HomeScreen(),
          '/questionnaire': (context) => QuestionnaireScreen(),
          '/profile': (context) => ProfileScreen(),
          '/personality_types': (context) => PersonalityTypesPage(),
          '/impressum': (context) => ImpressumPage(),
        },

        // 2) Handle unknown routes or typos gracefully
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) => HomeScreen());
        },
      ),
    );
  }
}