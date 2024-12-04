import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore access
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth

class SignInDialog extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool allowAnonymous;

  SignInDialog({
    required this.emailController,
    required this.passwordController,
    required this.allowAnonymous,
  });

  @override
  _SignInDialogState createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  bool _isAnimating = false; // Flag to control the success animation
  bool _isSignUpMode = true; // Flag to toggle between sign-in and sign-up

  // Controller for name input in sign-up form
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevents dismissing by back button
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Color(0xFFEDE8DB),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: _isAnimating
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 100),
                SizedBox(height: 20),
              ],
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isSignUpMode ? _buildSignUpForm() : _buildSignInForm(),
                SizedBox(height: 20),
                // Switch between modes
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
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Build Sign In Form
  Widget _buildSignInForm() {
    return Column(
      children: [
        // Email Input
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

        // Password Input
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

        // Forgot Password
        TextButton(
          onPressed: _resetPassword,
          child: Text(
            'Passwort vergessen?',
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
        SizedBox(height: 20),

        // Sign In Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            backgroundColor: Color(0xFFCB9935),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          onPressed: _signIn,
          child: Text('Anmelden'),
        ),
        SizedBox(height: 20),

        // Continue Without Account (conditionally displayed)
        if (widget.allowAnonymous)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: _continueWithoutAccount,
            child: Text(
              'Ohne Account fortfahren',
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            ),
          ),

        // Error Message
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
      ],
    );
  }

  // Build Sign Up Form
  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline
        Text(
          'Warum ein Konto erstellen?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        SizedBox(height: 20),
        // Reasons
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
          text:
          'Du kannst regelmäßige News bekommen, die dich auf das nächste Level bringen',
        ),
        SizedBox(height: 40),

        // Name Input
        TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Vorname'),
        ),
        SizedBox(height: 20),

        // Email Input
        TextField(
          controller: widget.emailController,
          decoration: InputDecoration(labelText: 'Email-Adresse'),
        ),
        SizedBox(height: 20),

        // Password Input
        TextField(
          controller: widget.passwordController,
          decoration: InputDecoration(labelText: 'Kennwort'),
          obscureText: true,
        ),
        SizedBox(height: 20),

        // Sign Up Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            backgroundColor: Color(0xFFCB9935),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          onPressed: _signUp,
          child: Text('Registrieren'),
        ),

        SizedBox(height: 20),

        // Continue Without Account (conditionally displayed)
        if (widget.allowAnonymous)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onPressed: _continueWithoutAccount,
            child: Text(
              'Ohne Account fortfahren',
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            ),
          ),

        // Error Message
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
      ],
    );
  }

  // Build Reason Card
  Widget _buildReasonCard({required IconData icon, required String text}) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Color(0xFFCB9935)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Functions for Button Actions

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
      // Speichere den aktuellen Benutzer (vor dem Login)
      User? previousUser = authService.user;

      // Melde den Benutzer mit E-Mail und Passwort an
      await authService.signInWithEmail(
        widget.emailController.text,
        widget.passwordController.text,
      );

      // Überprüfe, ob die Anmeldung erfolgreich war
      if (authService.user != null) {
        // Wenn der vorherige Benutzer anonym war, mergen wir die Daten
        if (previousUser != null && previousUser.isAnonymous) {
          await mergeAnonymousDataWithUser(previousUser, authService.user!);

          // Lösche das anonyme Benutzerkonto
          await previousUser.delete();
        }

        setState(() {
          _isAnimating = true;
        });
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
      } else {
        _showMessage(
          authService.errorMessage ?? "Anmeldung fehlgeschlagen.",
          Colors.red,
        );
      }
    } on FirebaseAuthException catch (e) {
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
      _showMessage("Ein Fehler ist aufgetreten.", Colors.red);
    }
  }


  void _signUp() async {
    if (widget.emailController.text.isNotEmpty &&
        isValidEmail(widget.emailController.text)) {
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        // Speichere den aktuellen Benutzer (vor der Registrierung)
        User? currentUser = authService.user;

        // Erstelle Anmeldeinformationen mit E-Mail und Passwort
        AuthCredential credential = EmailAuthProvider.credential(
          email: widget.emailController.text,
          password: widget.passwordController.text,
        );

        if (currentUser != null && currentUser.isAnonymous) {
          // Verknüpfe das anonyme Konto mit dem E-Mail/Passwort-Konto
          UserCredential userCredential = await currentUser.linkWithCredential(credential);

          // Aktualisiere den Anzeigenamen des Benutzers
          await userCredential.user!.updateDisplayName(nameController.text);
          await userCredential.user!.reload();

          // Speichere Benutzerdaten in Firestore
          FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'displayName': nameController.text,
            'email': widget.emailController.text,
          });

          // Abonniere den Benutzer zum Newsletter
          await subscribeToNewsletter(
            widget.emailController.text,
            nameController.text,
          );

          setState(() {
            _isAnimating = true;
          });

          // Schließe den Dialog nach 2 Sekunden
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
        } else {
          // Kein anonymer Benutzer, normaler Registrierungsprozess
          await authService.signUpWithEmail(
            widget.emailController.text,
            widget.passwordController.text,
          );

          // Aktualisiere den Anzeigenamen des Benutzers
          await authService.user!.updateDisplayName(nameController.text);
          await authService.user!.reload();

          // Speichere Benutzerdaten in Firestore
          FirebaseFirestore.instance
              .collection('users')
              .doc(authService.user!.uid)
              .set({
            'displayName': nameController.text,
            'email': widget.emailController.text,
          });

          // Abonniere den Benutzer zum Newsletter
          await subscribeToNewsletter(
            widget.emailController.text,
            nameController.text,
          );

          setState(() {
            _isAnimating = true;
          });

          // Schließe den Dialog nach 2 Sekunden
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
        }
      } on FirebaseAuthException catch (e) {
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
        _showMessage("Ein Fehler ist aufgetreten.", Colors.red);
      }
    } else {
      _showMessage('Bitte gebe eine gültige E-Mail-Adresse ein.', Colors.red);
    }
  }



  void _continueWithoutAccount() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signInAnonymously(); // Sign in anonymously
    setState(() {
      _isAnimating = true;
    });
    // Wait for 2 seconds, then close the dialog
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  // Function to display messages
  void _showMessage(String message, Color backgroundColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        backgroundColor: backgroundColor,
        actions: [
          TextButton(
            child: Text('OK', style: TextStyle(color: Colors.white)),
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

  Future<void> mergeAnonymousDataWithUser(
      User anonymousUser, User signedInUser) async {
    if (!anonymousUser.isAnonymous) return;

    final anonymousUserRef =
    FirebaseFirestore.instance.collection('users').doc(anonymousUser.uid);
    final signedInUserRef =
    FirebaseFirestore.instance.collection('users').doc(signedInUser.uid);

    // Get existing 'results' collections in signed-in user's data
    List<String> signedInUserResultsCollections =
    await getResultsCollections(signedInUserRef);

    // Determine the highest 'results_x' number in the signed-in user's data
    int maxResultNumber = 0;
    for (String collectionId in signedInUserResultsCollections) {
      if (collectionId == 'results') {
        maxResultNumber = maxResultNumber > 1 ? maxResultNumber : 1;
      } else if (collectionId.startsWith('results_')) {
        int number =
            int.tryParse(collectionId.substring('results_'.length)) ?? 0;
        if (number > maxResultNumber) {
          maxResultNumber = number;
        }
      }
    }

    // Get the anonymous user's 'results' collections
    List<String> anonymousUserResultsCollections =
    await getResultsCollections(anonymousUserRef);

    // Now copy each of the anonymous user's 'results' subcollections
    for (String collectionId in anonymousUserResultsCollections) {
      // Increment the maxResultNumber
      maxResultNumber += 1;
      String newCollectionId = 'results_${maxResultNumber}';

      // Copy documents from anonymous subcollection to the signed-in user's new subcollection
      final anonymousCollectionRef = anonymousUserRef.collection(collectionId);
      final anonymousDocs = await anonymousCollectionRef.get();
      for (DocumentSnapshot doc in anonymousDocs.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await signedInUserRef
              .collection(newCollectionId)
              .doc(doc.id)
              .set(data);
        } else {
          print('Document ${doc.id} has no data.');
        }
      }
    }

    // Optionally delete the anonymous user's data
    await deleteUserData(anonymousUser.uid);
  }

  // Helper function to delete user data
  Future<void> deleteUserData(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    // Get the list of 'results' collections
    List<String> resultsCollections = await getResultsCollections(userRef);

    // Delete documents in each subcollection
    for (String collectionId in resultsCollections) {
      final collectionRef = userRef.collection(collectionId);
      final snapshot = await collectionRef.get();
      for (DocumentSnapshot doc in snapshot.docs) {
        await collectionRef.doc(doc.id).delete();
      }
    }

    // Delete the user document
    await userRef.delete();
  }

  // Helper function to get 'results' collections from a user's document
  Future<List<String>> getResultsCollections(DocumentReference userRef) async {
    List<String> resultsCollections = [];

    // Attempt to find collections named 'results', 'results_1', up to 'results_100'
    for (int i = 0; i <= 100; i++) {
      String collectionId = i == 0 ? 'results' : 'results_$i';
      final collectionRef = userRef.collection(collectionId);
      // Try to read a single document to see if the collection exists
      final snapshot = await collectionRef.limit(1).get();
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
