// mobile_sidebar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personality_score/auth/auth_service.dart';

class MobileSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            child: Text('Menu', style: TextStyle(fontSize: 24)),
          ),
          ListTile(
            title: Text('PERSONALITY SCORE'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/home');
            },
          ),
          ListTile(
            title: Text('Personality Types'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/personality_types');
            },
          ),
          Consumer<AuthService>(
            builder: (context, authService, child) {
              return ListTile(
                title: Text('Profile'),
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
    );
  }
}
