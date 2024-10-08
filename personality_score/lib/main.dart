import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:personality_score/screens/questionnaire_screen.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'firebase_options.dart'; // Ensure you have this file generated
import 'package:personality_score/screens/profile_screen.dart';
import 'package:personality_score/models/questionaire_model.dart';
import 'package:personality_score/screens/personality_type_screen.dart'; // Import the new screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          '/signin': (context) => SignInScreen(),
          '/signup': (context) => SignUpScreen(),
          '/home': (context) => HomeScreen(),
          '/questionnaire': (context) => QuestionnaireScreen(),
          '/profile': (context) => ProfileScreen(),
          '/personality_types': (context) => PersonalityTypesPage(),
          '/impressum': (context) => ImpressumPage(), // Add this route
          '/datenschutz': (context) => DatenschutzPage(), // Add this route
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