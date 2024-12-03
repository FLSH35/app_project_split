// mobile_sidebar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:personality_score/screens/signin_dialog.dart';


class MobileSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFFF7F5EF).withOpacity(0.8), // Half-transparent background
      child: Container(
        child: Align(
          alignment: Alignment.topLeft, // Align content to the top
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5, // Limit height to content
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Only take up space required by content
              children: [
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
                    child: Image.asset(
                      'assets/Logo-IYC-gross.png',
                      height: 40,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('ALLGEMEIN'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/home');
                  },
                ),
                ListTile(
                  title: Text('STUFEN'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/personality_types');
                  },
                ),
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return ListTile(
                      title: Text('PROFIL'),
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
      ),
    );
  }

  // Add the showSignInDialog function
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
      // Dispose controllers when the dialog is closed
      emailController.dispose();
      passwordController.dispose();
    });
  }


}
