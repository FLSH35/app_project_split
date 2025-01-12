import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
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
                  'Impressum',
                  style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url); // Use Uri to parse the URL

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);  // Use launchUrl instead of launch
    } else {
      throw 'Could not launch $url';
    }
  }

}
