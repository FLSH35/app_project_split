// lib/screens/desktop_layout/desktop_tutorial_section.dart
import 'package:flutter/material.dart';

class DesktopTutorialSection extends StatefulWidget {
  const DesktopTutorialSection({Key? key}) : super(key: key);

  @override
  State<DesktopTutorialSection> createState() => _DesktopTutorialSectionState();
}

class _DesktopTutorialSectionState extends State<DesktopTutorialSection> {
  bool isLoading = true;
  final List<String> tutorialQuestions = [
    'Mit dem Schieberegler kann ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich schnell, ...',
    'Ich antworte ehrlich und gewissenhaft.',
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      key: const Key('desktopTutorialSection'), // falls du es scrollen willst
      children: [
        const SizedBox(height: 40),
        // Hier könnten weitere Widgets sein (Video, Buttons, etc.)
        ...tutorialQuestions.map((q) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(q, style: const TextStyle(fontSize: 18)),
        )),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            // Navigator.of(context).pushNamed('/questionnaire');
          },
          child: const Text('Beginne den Test'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
