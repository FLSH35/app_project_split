// lib/screens/desktop_layout/desktop_tutorial_section.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../helper_functions/questionnaire_helpers.dart';
import '../../helper_functions/video_helper.dart';

class DesktopTutorialSection extends StatefulWidget {
  const DesktopTutorialSection({Key? key}) : super(key: key);

  @override
  State<DesktopTutorialSection> createState() => _DesktopTutorialSectionState();
}

class _DesktopTutorialSectionState extends State<DesktopTutorialSection> {
  bool isLoading = false;
  final List<String> tutorialQuestions = [
    'Ich kann meine Zeit frei einteilen, ohne dass mein Business darunter leidet.',
    'Ich fühle mich mental frei und ohne ständigen Druck.',
    'Ich habe eine klare Strategie, um finanzielle und zeitliche Freiheit zu erreichen.',
  ];
  Map<int, int> answers = {};
  final GlobalKey _tutorialKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _tutorialKey, // Add the key here
      child: Column(
        children: [
          SizedBox(height: 40),
          _buildQuestionsList(context),
          SizedBox(height: 40),
          _buildNavigationButton(context),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context) {
    int start = 0 * 3;
    int end = start + 3;
    List<String> currentQuestions = tutorialQuestions.sublist(
      start,
      end > tutorialQuestions.length ? tutorialQuestions.length : end,
    );

    return Column(
      children: currentQuestions.map((questionText) {
        int questionIndex = start + currentQuestions.indexOf(questionText);
        return Container(
          height: MediaQuery.of(context).size.height / 4,
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: MediaQuery.of(context).size.width / 5,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: SelectableText(
                  questionText,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Roboto',
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
              SizedBox(height: 8.0),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Row of vertical lines with margin to align with slider divisions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(11, (index) {
                              return Container(
                                width: 1,
                                height: 20,
                                color: Colors.grey,
                              );
                            }),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0),
                    ],
                  ),
                  // The slider itself
                  Slider(
                    value: (answers[questionIndex] ?? 5).toDouble(),
                    onChanged: (val) {
                      setState(() {
                        answers[questionIndex] = val.toInt();
                      });
                    },
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: Color(0xFFCB9935),
                    inactiveColor: Colors.grey,
                    thumbColor: Color(0xFFCB9935),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableText(
                    'NEIN',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SelectableText(
                    'EHER NEIN',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SelectableText(
                    'NEUTRAL',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SelectableText(
                    'EHER JA',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SelectableText(
                    'JA',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    return isLoading
        ? SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCB9935)),
        strokeWidth: 2.0,
      ),
    )
        : ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFCB9935),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      onPressed: isLoading
          ? null
          : () async {
        setState(() {
          isLoading = true;
        });
        await handleTakeTest(context);
        setState(() {
          isLoading = false;
        });
      },
      child: Text(
        'Starte jetzt',
        style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 16),
      ),
    );
  }
}