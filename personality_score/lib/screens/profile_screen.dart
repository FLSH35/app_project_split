// profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../auth/auth_service.dart';
import 'profile_desktop_layout.dart'; // Ensure this import is correct
import 'profile_mobile_layout.dart'; // Ensure this import is correct

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditingName = false;
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_DE', null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: ProfileMobileLayout(
        nameController: _nameController,
        isEditingName: _isEditingName,
        onEditName: () {
          setState(() {
            _isEditingName = true;
          });
        },
        onSaveName: updateUserName,
      ), // Mobile layout
      desktop: ProfileDesktopLayout(
        nameController: _nameController,
        isEditingName: _isEditingName,
        onEditName: () {
          setState(() {
            _isEditingName = true;
          });
        },
        onSaveName: updateUserName,
      ), // Desktop layout
    );
  }

  /// Update the user's display name
  Future<void> updateUserName() async {
    final user = Provider.of<AuthService>(context, listen: false).user;

    if (user != null && _nameController.text.isNotEmpty) {
      try {
        // Update Firebase Authentication profile
        await user.updateDisplayName(_nameController.text);
        await user.reload();

        // Update Firestore user document
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'displayName': _nameController.text,
        });

        setState(() {
          _isEditingName = false;
        });

        // Refresh the name displayed in the UI
        _nameController.text = user.displayName ?? '';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name erfolgreich aktualisiert.')),
        );
      } catch (e) {
        print('Error updating user name: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren des Namens.')),
        );
      }
    }
  }
}
