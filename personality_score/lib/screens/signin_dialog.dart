import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class SignInDialog extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool allowAnonymous;

  /// Route, zu der nach erfolgreichem Login/Sign-up navigiert werden soll.
  final String nextRoute;

  SignInDialog({
    required this.emailController,
    required this.passwordController,
    required this.allowAnonymous,
    this.nextRoute = '/home', // Default, falls nichts übergeben wird
  });

  @override
  _SignInDialogState createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  bool _isAnimating = false; // Flag für Erfolg-Animation
  bool _isSignUpMode = true; // Flag für Umschalten zw. Registrieren/Anmelden
  bool _isLoading = false;   // Flag für Ladezustand

  final TextEditingController nameController = TextEditingController(); // Name-Eingabe nur beim Registrieren

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Schließen via Back-Button verhindern
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFEDE8DB),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SingleChildScrollView(
                child: _isAnimating
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 100),
                    SizedBox(height: 20),
                  ],
                )
                    : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isSignUpMode
                        ? _buildSignUpForm()
                        : _buildSignInForm(),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUpMode = !_isSignUpMode;
                        });
                      },
                      child: Text(
                        _isSignUpMode
                            ? 'Hast du bereits einen Account? Hier anmelden!'
                            : 'Noch keinen Account? Hier registrieren!',
                        style: const TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Den X-Button nur anzeigen, wenn NICHT die Erfolgsanimation läuft:
            if (!_isAnimating)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/home');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Formular: Anmelden
  Widget _buildSignInForm() {
    return Column(
      children: [
        TextField(
          controller: widget.emailController,
          decoration: const InputDecoration(
            labelText: 'E-Mail',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: widget.passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Passwort',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _resetPassword,
          child: const Text(
            'Passwort vergessen?',
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            backgroundColor: const Color(0xFFCB9935),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          onPressed: _isLoading ? null : _signIn,
          child: const Text('Anmelden'),
        ),
        const SizedBox(height: 20),
        if (widget.allowAnonymous)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: _isLoading ? null : _continueWithoutAccount,
            child: const Text(
              'Ohne Account fortfahren',
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            ),
          ),
        Consumer<AuthService>(
          builder: (context, authService, child) {
            if (authService.errorMessage != null) {
              return SelectableText(
                authService.errorMessage!,
                style: const TextStyle(color: Colors.red),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  // Formular: Registrieren
  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Warum ein Konto erstellen?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 20),
        _buildReasonCard(
          icon: Icons.save,
          text: 'Alte Ergebnisse werden gespeichert',
        ),
        _buildReasonCard(
          icon: Icons.trending_up,
          text: 'Du kannst deine Weiterentwicklung messen',
        ),
        _buildReasonCard(
          icon: Icons.email,
          text: 'Du kannst regelmäßige News bekommen, die dich auf das nächste Level bringen',
        ),
        const SizedBox(height: 40),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Vorname'),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: widget.emailController,
          decoration: const InputDecoration(labelText: 'Email-Adresse'),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: widget.passwordController,
          decoration: const InputDecoration(labelText: 'Kennwort'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            backgroundColor: const Color(0xFFCB9935),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          onPressed: _isLoading ? null : _signUp,
          child: const Text('Registrieren'),
        ),
        const SizedBox(height: 20),
        if (widget.allowAnonymous)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: _isLoading ? null : _continueWithoutAccount,
            child: const Text(
              'Ohne Account fortfahren',
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            ),
          ),
        Consumer<AuthService>(
          builder: (context, authService, child) {
            if (authService.errorMessage != null) {
              return SelectableText(
                authService.errorMessage!,
                style: const TextStyle(color: Colors.red),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  // Hilfs-Widget für die "Warum ein Konto erstellen?"-Karten
  Widget _buildReasonCard({required IconData icon, required String text}) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFCB9935)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- Actions & Helferfunktionen --------------------

  void _resetPassword() async {
    if (widget.emailController.text.isNotEmpty) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.sendPasswordResetEmail(widget.emailController.text);
      _showMessage(
        "Link zum Zurücksetzen des Passworts wurde an ${widget.emailController.text} gesendet.",
        Colors.green,
      );
    } else {
      _showMessage("Bitte geben Sie Ihre E-Mail-Adresse ein.", Colors.red);
    }
  }

  void _signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      User? previousUser = authService.user; // aktueller User (könnte anonym sein)
      setState(() => _isLoading = true);

      // Anmelden
      await authService.signInWithEmail(
        widget.emailController.text,
        widget.passwordController.text,
      );

      if (authService.user != null) {
        // Anonyme Daten mergen, falls vorheriger User anonym war
        if (previousUser != null && previousUser.isAnonymous) {
          await mergeAnonymousDataWithUser(previousUser, authService.user!);
        }

        setState(() {
          _isAnimating = true;
          _isLoading = false;
        });

        // Nach kurzer Verzögerung weiterleiten
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pushReplacementNamed(widget.nextRoute);
        });
      } else {
        setState(() => _isLoading = false);
        _showMessage(
          authService.errorMessage ?? "Anmeldung fehlgeschlagen.",
          Colors.red,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "Kein Benutzer mit dieser E-Mail gefunden.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Falsches Passwort.";
      } else {
        errorMessage = e.message ?? "Anmeldung fehlgeschlagen.";
      }
      _showMessage(errorMessage, Colors.red);
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("Ein Fehler ist aufgetreten.", Colors.red);
    }
  }

  void _signUp() async {
    if (widget.emailController.text.isNotEmpty &&
        isValidEmail(widget.emailController.text)) {
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        setState(() => _isLoading = true);

        // aktueller User (könnte anonym sein)
        User? currentUser = authService.user;

        AuthCredential credential = EmailAuthProvider.credential(
          email: widget.emailController.text,
          password: widget.passwordController.text,
        );

        // Falls der aktuelle User anonym ist -> Link mit neuem Email/PW-Konto
        if (currentUser != null && currentUser.isAnonymous) {
          UserCredential userCredential =
          await currentUser.linkWithCredential(credential);

          // Anzeigenamen & Firestore updaten
          await userCredential.user!.updateDisplayName(nameController.text);
          await userCredential.user!.reload();
          FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'displayName': nameController.text,
            'email': widget.emailController.text,
          });

          await subscribeToNewsletter(
            widget.emailController.text,
            nameController.text,
          );

          setState(() {
            _isAnimating = true;
            _isLoading = false;
          });

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacementNamed(widget.nextRoute);
          });
        } else {
          // Normaler Registrierungsprozess
          await authService.signUpWithEmail(
            widget.emailController.text,
            widget.passwordController.text,
          );

          // Anzeigenamen & Firestore updaten
          await authService.user!.updateDisplayName(nameController.text);
          await authService.user!.reload();
          FirebaseFirestore.instance
              .collection('users')
              .doc(authService.user!.uid)
              .set({
            'displayName': nameController.text,
            'email': widget.emailController.text,
          });

          await subscribeToNewsletter(
            widget.emailController.text,
            nameController.text,
          );

          setState(() {
            _isAnimating = true;
            _isLoading = false;
          });

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacementNamed(widget.nextRoute);
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage = "E-Mail ist bereits registriert.";
        } else if (e.code == 'weak-password') {
          errorMessage = "Das Passwort ist zu schwach.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Ungültige E-Mail-Adresse.";
        } else if (e.code == 'credential-already-in-use') {
          errorMessage = "Diese E-Mail ist bereits registriert.";
        } else {
          errorMessage = e.message ?? "Registrierung fehlgeschlagen.";
        }
        _showMessage(errorMessage, Colors.red);
      } catch (e) {
        setState(() => _isLoading = false);
        _showMessage("Ein Fehler ist aufgetreten.", Colors.red);
      }
    } else {
      _showMessage('Bitte gebe eine gültige E-Mail-Adresse ein.', Colors.red);
    }
  }

  void _continueWithoutAccount() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() => _isLoading = true);
    await authService.signInAnonymously();
    setState(() {
      _isAnimating = true;
      _isLoading = false;
    });
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacementNamed(widget.nextRoute);
    });
  }

  // Einfache Helper-Methode für Fehlermeldungen
  void _showMessage(String message, Color backgroundColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        backgroundColor: backgroundColor,
        actions: [
          TextButton(
            child: const Text('OK', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  // Zusammenführen anonymer Daten mit dem registrierten Benutzer
  Future<void> mergeAnonymousDataWithUser(
      User anonymousUser, User signedInUser) async {
    if (!anonymousUser.isAnonymous) return;

    final anonymousUserRef =
    FirebaseFirestore.instance.collection('users').doc(anonymousUser.uid);
    final signedInUserRef =
    FirebaseFirestore.instance.collection('users').doc(signedInUser.uid);

    List<String> signedInUserResultsCollections =
    await getResultsCollections(signedInUserRef);

    int maxResultNumber = 0;
    for (String collectionId in signedInUserResultsCollections) {
      if (collectionId == 'results') {
        maxResultNumber = (maxResultNumber > 1) ? maxResultNumber : 1;
      } else if (collectionId.startsWith('results_')) {
        int number = int.tryParse(collectionId.substring('results_'.length)) ?? 0;
        if (number > maxResultNumber) {
          maxResultNumber = number;
        }
      }
    }

    List<String> anonymousUserResultsCollections =
    await getResultsCollections(anonymousUserRef);

    for (String collectionId in anonymousUserResultsCollections) {
      maxResultNumber += 1;
      String newCollectionId = 'results_$maxResultNumber';

      final anonymousCollectionRef = anonymousUserRef.collection(collectionId);
      final anonymousDocs = await anonymousCollectionRef.get();
      for (DocumentSnapshot doc in anonymousDocs.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await signedInUserRef.collection(newCollectionId).doc(doc.id).set(data);
        }
      }
    }
    // ggf. Daten des anonymen Users löschen, wenn gewünscht
    await deleteUserData(anonymousUser.uid);
  }

  Future<void> deleteUserData(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    List<String> resultsCollections = await getResultsCollections(userRef);

    for (String collectionId in resultsCollections) {
      final collectionRef = userRef.collection(collectionId);
      final snapshot = await collectionRef.get();
      for (DocumentSnapshot doc in snapshot.docs) {
        await collectionRef.doc(doc.id).delete();
      }
    }

    await userRef.delete();
  }

  Future<List<String>> getResultsCollections(DocumentReference userRef) async {
    List<String> resultsCollections = [];
    for (int i = 0; i <= 100; i++) {
      String collectionId = i == 0 ? 'results' : 'results_$i';
      final snapshot = await userRef.collection(collectionId).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        resultsCollections.add(collectionId);
      }
    }
    return resultsCollections;
  }

  Future<void> subscribeToNewsletter(String email, String firstName) async {
    try {
      final Uri cloudFunctionUrl = Uri.parse(
        'https://us-central1-personality-score.cloudfunctions.net/manage_newsletter',
      );

      final response = await http.get(
        cloudFunctionUrl.replace(queryParameters: {
          'email': email,
          'first_name': firstName,
        }),
      );

      if (response.statusCode == 200) {
        print('Newsletter erfolgreich abonniert!');
      } else {
        print('Fehler beim Abonnieren des Newsletters: ${response.body}');
      }
    } catch (e) {
      print('Ein Fehler ist aufgetreten: $e');
    }
  }
}
