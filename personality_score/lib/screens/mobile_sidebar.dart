import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:personality_score/screens/signin_dialog.dart';

class MobileSidebar extends StatefulWidget {
  const MobileSidebar({Key? key}) : super(key: key);

  @override
  State<MobileSidebar> createState() => _MobileSidebarState();
}

class _MobileSidebarState extends State<MobileSidebar> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF7F5EF).withOpacity(0.8),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5, // Höhe begrenzen
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo-Bereich
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36.0),
                child: GestureDetector(
                  onTap: () async {
                    const url = 'https://ifyouchange.com/';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/Logo-IYC-gross.png',
                    ),
                  ),
                ),
              ),

              // Hier kommt der Bereich: entweder "Anmelden"-Button oder User-Icon + Name
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  final user = authService.user;

                  // Falls der Nutzer noch nicht eingeloggt ist oder kein displayName hat
                  if (user == null || user.displayName == null) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFCB9935)),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => SignInDialog(
                            emailController: TextEditingController(),
                            passwordController: TextEditingController(),
                            allowAnonymous: false,
                            nextRoute: '/profile', // optional: wohin nach Login?
                          ),
                        ).then((_) {
                          // Nach dem Schließen des Dialogs AuthService abfragen
                          final updatedAuthService =
                          Provider.of<AuthService>(context, listen: false);

                          // Prüfen, ob User existiert und displayName gesetzt ist
                          if (updatedAuthService.user != null &&
                              updatedAuthService.user!.displayName != null) {
                            setState(() {
                              _nameController.text =
                              updatedAuthService.user!.displayName!;
                            });
                            // Hier könntest du weitere Daten abrufen, falls nötig
                          } else {
                            // Falls Anmeldung fehlschlägt
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Anmeldung fehlgeschlagen. Bitte versuchen Sie es erneut.',
                                ),
                              ),
                            );
                          }
                        });
                      },
                      child: const Text(
                        'Anmelden',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    );
                  } else {
                    // User eingeloggt und Name vorhanden -> Nutzer-Icon + Name anzeigen
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.displayName!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),

              // Ab hier die restlichen ListTiles
              ListTile(
                title: const Text('ALLGEMEIN'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/home');
                },
              ),
              ListTile(
                title: const Text('EINSTUFUNG'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/personality_types');
                },
              ),
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  return ListTile(
                    title: const Text('PROFIL'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/profile');
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Diese Methode kannst du weiterverwenden, falls du sie in anderer Form benötigst
  void showSignInDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => SignInDialog(
        emailController: emailController,
        passwordController: passwordController,
        allowAnonymous: false,
      ),
    ).then((_) {
      // Dispose der Controller nicht vergessen
      emailController.dispose();
      passwordController.dispose();
    });
  }
}
