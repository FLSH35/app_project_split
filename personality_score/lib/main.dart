import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:personality_score/screens/home_screen/home_screen.dart';
import 'package:personality_score/screens/questionnaire_screen.dart';
import 'package:personality_score/splash_screen.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'firebase_options.dart';
import 'package:personality_score/screens/profile_screen.dart';
import 'package:personality_score/models/questionaire_model.dart';
import 'package:personality_score/screens/personality_type_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';

// ...

Future<void> checkForUpdates() async {
  final packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  final snapshot = await FirebaseFirestore.instance
      .collection('appConfig')
      .doc('latestVersion')
      .get();

  if (snapshot.exists) {
    String latestVersion = snapshot['version'];

    if (latestVersion != currentVersion) {
      html.window.location.reload();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        theme: ThemeData(primarySwatch: Colors.blue),

        // Du kannst entweder den Splash Screen direkt setzen ...
        home: const SplashScreen(),

        // ... oder weiterhin mit Routen arbeiten
        // initialRoute: Routes.splashScreen,
        // onGenerateRoute: Routes.controller,
      ),
    );
  }
}

// Bei den Routes kannst du optional eine '/splash' Route hinzufügen
class Routes {
  static const String home = '/home';
  static const String questionnaire = '/questionnaire';
  static const String profile = '/profile';
  static const String personalityTypes = '/personality_types';
  // static const String splash = '/splash';

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
    // case splash:
    //   return MaterialPageRoute(builder: (context) => SplashScreen());

      default:
        return MaterialPageRoute(builder: (context) => HomeScreen());
    }
  }
}
