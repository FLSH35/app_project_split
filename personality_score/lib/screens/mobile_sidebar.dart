// mobile_sidebar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';

class MobileSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white.withOpacity(0.8), // Half-transparent background
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
                SizedBox(height: 50),
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
                        if (authService.user == null) {
                          Navigator.of(context).pushNamed('/signin');
                        } else {
                          Navigator.of(context).pushNamed('/profile');
                        }
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
}
