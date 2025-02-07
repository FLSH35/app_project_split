import 'package:flutter/material.dart';
class CustomFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Color(0xFFF7F5EF), // Same soft background color as the app bar
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/impressum');
                },
                child: Text(
                  'IMPRESSUM & DATENSCHUTZ',
                  style: TextStyle(
                      color: Colors.black, fontSize: 18, fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
