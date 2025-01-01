import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:personality_score/screens/signin_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo Section
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

              // "Allgemein" ListTile with Icon
              ListTile(
                leading: const Icon(
                  Icons.home_outlined,
                  color: Colors.black,
                  size: 30,
                ),
                title: const Text(
                  'Allgemein',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/home');
                },
              ),

              // "Einstufung" ListTile with Icon
              ListTile(
                leading: const Icon(
                  Icons.stairs,
                  color: Colors.black,
                  size: 30,
                ),
                title: const Text(
                  'Einstufung',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/personality_types');
                },
              ),

              // Login or Profile Section
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  final user = authService.user;

                  if (user == null || user.displayName == null) {
                    // Not logged in
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
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
                                nextRoute: '/profile',
                              ),
                            ).then((_) {
                              final updatedAuthService =
                              Provider.of<AuthService>(context, listen: false);

                              if (updatedAuthService.user != null &&
                                  updatedAuthService.user!.displayName != null) {
                                setState(() {
                                  _nameController.text =
                                  updatedAuthService.user!.displayName!;
                                });
                              } else {
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
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Logged in, display final character image and name
                    return ListTile(
                              leading: FutureBuilder<String>(
    future: _fetchFinalCharacter(authService.user!),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCB9935)),
    strokeWidth: 2.0,
    );
    }

    String character = snapshot.data ?? "Explorer";

    return Image.asset(
                                'assets/$character.webp',
                                height: 30.0,
                              );}

                              ),
                              title: Text(
                                authService.user!.displayName ?? "User",
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/profile');
                            },
                          );

                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _fetchFinalCharacter(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['currentFinalCharacter'] ?? 'Explorer';
      }
    } catch (error) {
      print("Error fetching FinalCharacter: $error");
    }
    return 'Explorer'; // Default character
  }

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
      emailController.dispose();
      passwordController.dispose();
    });
  }
}