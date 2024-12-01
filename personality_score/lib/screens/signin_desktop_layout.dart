import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Für Firestore-Zugriff
import 'custom_app_bar.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';

class SignInDesktopLayout extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  SignInDesktopLayout({
    required this.emailController,
    required this.passwordController,
  });

  @override
  _SignInDesktopLayoutState createState() => _SignInDesktopLayoutState();
}

class _SignInDesktopLayoutState extends State<SignInDesktopLayout> {
  bool _isSignedIn = false; // Status, ob der Benutzer angemeldet ist
  String? userName; // Variable für den Benutzernamen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Anmeldung - Desktop',
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!_isSignedIn) ...[
                    // Eingabe für Email
                    TextField(
                      controller: widget.emailController,
                      decoration: InputDecoration(
                        labelText: 'E-Mail',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 20),

                    // Eingabe für Passwort
                    TextField(
                      controller: widget.passwordController,
                      decoration: InputDecoration(
                        labelText: 'Passwort',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 20),

                    // Passwort vergessen
                    TextButton(
                      onPressed: () async {
                        if (widget.emailController.text.isNotEmpty) {
                          final authService = Provider.of<AuthService>(context, listen: false);
                          await authService.sendPasswordResetEmail(widget.emailController.text);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: SelectableText(
                                "Link zum Zurücksetzen des Passworts wurde an ${widget.emailController.text} gesendet."),
                            backgroundColor: Colors.green,
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: SelectableText("Bitte geben Sie Ihre E-Mail-Adresse ein."),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                      child: Text(
                        'Passwort vergessen?',
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Registrierung
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/signup');
                      },
                      child: Text(
                        'Noch keinen Account? Hier registrieren!',
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Anmelden-Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        backgroundColor: Color(0xFFCB9935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () async {
                        final authService = Provider.of<AuthService>(context, listen: false);
                        await authService.signInWithEmail(
                          widget.emailController.text,
                          widget.passwordController.text,
                        );
                        if (authService.user != null) {
                          await fetchUserName(); // Benutzername abrufen
                          setState(() {
                            _isSignedIn = true; // Erfolgreich angemeldet
                          });
                        }
                      },
                      child: Text('Anmelden'),
                    ),
                    SizedBox(height: 20),

                    // Ohne Account fortfahren
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () async {
                        final authService = Provider.of<AuthService>(context, listen: false);
                        await authService.signInAnonymously(); // Anonym anmelden
                        handleTakeTest(context); // Direkt zum Test
                      },
                      child: Text(
                        'Ohne Account fortfahren',
                        style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                      ),
                    ),

                    // Fehlernachricht
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        if (authService.errorMessage != null) {
                          return SelectableText(
                            authService.errorMessage!,
                            style: TextStyle(color: Colors.red),
                          );
                        }
                        return Container();
                      },
                    ),
                  ] else ...[
                    // Begrüßung nach Anmeldung
                    if (userName != null)
                      Text(
                        'Hallo $userName!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    SizedBox(height: 20),

                    // Test starten
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        backgroundColor: Color(0xFFCB9935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () {
                        handleTakeTest(context); // Zum Test
                      },
                      child: Text(
                        'Beginne den Test',
                        style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                      ),
                    ),SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCB9935),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                      child: Text(
                        'Zum Profil',
                        style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFEDE8DB),
    );
  }

  Future<void> fetchUserName() async {
    final user = Provider.of<AuthService>(context, listen: false).user;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            userName = userData['name'];
          });
        }
      }
    }
  }
}
