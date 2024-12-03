import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore access
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'package:http/http.dart' as http;

class SignInDialog extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool allowAnonymous; // New required parameter

  SignInDialog({
    required this.emailController,
    required this.passwordController,
    required this.allowAnonymous, // Initialize the new parameter
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
    return Dialog(
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
              Text(
                'Erfolgreich angemeldet!',
                style:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
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
    await authService.signInWithEmail(
      widget.emailController.text,
      widget.passwordController.text,
    );
    if (authService.user != null) {
      setState(() {
        _isAnimating = true;
      });
      // Wait for 2 seconds, then close the dialog
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
        // Navigate to the next screen if needed
        handleTakeTest(context); // Or any other navigation
      });
    } else {
      // Show error
      _showMessage(
          authService.errorMessage ?? "Anmeldung fehlgeschlagen.", Colors.red);
    }
  }

  void _signUp() async {
    if (widget.emailController.text.isNotEmpty &&
        isValidEmail(widget.emailController.text)) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signUpWithEmail(
        widget.emailController.text,
        widget.passwordController.text,
      );
      if (authService.user != null) {
        // Update the user's display name
        await authService.user!.updateDisplayName(nameController.text);
        await authService.user!.reload();

        // Optionally save the user data in Firestore
        FirebaseFirestore.instance
            .collection('users')
            .doc(authService.user!.uid)
            .set({
          'displayName': nameController.text,
          'email': widget.emailController.text,
        });

        // Subscribe user to the newsletter
        try {
          final Uri cloudFunctionUrl = Uri.parse(
            'https://us-central1-personality-score.cloudfunctions.net/manage_newsletter',
          );

          final response = await http.get(
            cloudFunctionUrl.replace(queryParameters: {
              'email': widget.emailController.text,
              'first_name': nameController.text,
            }),
          );

          if (response.statusCode == 200) {
            print('Newsletter erfolgreich abonniert!');
          } else {
            print(
                'Fehler beim Abonnieren des Newsletters: ${response.body}');
          }
        } catch (e) {
          print('Ein Fehler ist aufgetreten: $e');
        }

        setState(() {
          _isAnimating = true;
        });
        // Wait for 2 seconds, then close the dialog
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
          // Navigate to next screen if needed
          handleTakeTest(context); // Or any other navigation
        });
      } else {
        // Show error
        _showMessage(
            authService.errorMessage ?? "Registrierung fehlgeschlagen.",
            Colors.red);
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
      handleTakeTest(context); // Go to the test
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
}
