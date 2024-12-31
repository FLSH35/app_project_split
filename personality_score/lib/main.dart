import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:personality_score/screens/home_screen/home_screen.dart';
import 'package:personality_score/screens/questionnaire_screen.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
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
        // initialRoute & routes kommen aus routes.dart
        initialRoute: Routes.home,
        onGenerateRoute: Routes.controller,
      ),
    );
  }
}


class Routes {
  static const String home = '/home';
  static const String questionnaire = '/questionnaire';
  static const String profile = '/profile';
  static const String personalityTypes = '/personality_types';

  static Route<dynamic> controller(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => HomeScreen());
      case questionnaire:
        return MaterialPageRoute(builder: (context) => QuestionnaireScreen());
      case profile:
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case personalityTypes:
        return MaterialPageRoute(builder: (context) => PersonalityTypesPage());

      default:
      // Default/Fallback Route:
        return MaterialPageRoute(builder: (context) => HomeScreen());
    }
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