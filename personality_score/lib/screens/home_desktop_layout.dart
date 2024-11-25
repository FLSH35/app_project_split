// desktop_layout.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:personality_score/screens/pdf_viewer_screen.dart';
import 'custom_app_bar.dart'; // Import your custom app bar
import 'custom_footer.dart'; // Import your custom footer
import 'dart:math'; // For 3D transformations
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DesktopLayout extends StatefulWidget {
  @override
  _DesktopLayoutState createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  bool isLoading = true;
  List<String> tutorialQuestions = [
    'Mit dem Schieberegler kann ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich schnell, ohne lange nachzudenken.',
    'Ich antworte ehrlich und gewissenhaft.',
  ];
  final List<Map<String, String>> testimonials = [
    {
      "name": "Andrés",
      "text": "Der Personality Score hat mir geholfen, meine Stärken besser zu erkennen und meine Ziele klarer zu definieren.",
      "image": "testimonials/Andres.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Jana",
      "text": "Ein tolles Tool, das mir geholfen hat, einen Schritt weiter in meiner Persönlichkeitsentwicklung zu gehen.",
      "image": "testimonials/Jana.jpg",
      "personalityType": "Traveller",
    },
    {
      "name": "Christoph",
      "text": "Ich liebe die Klarheit, die der Test mir gebracht hat. Eine Bereicherung für jeden, der wachsen will!",
      "image": "testimonials/Christoph.jpg",
      "personalityType": "Individual",
    },
  ];

  Map<int, int> answers = {};
  int currentPage = 0;
  int questionsPerPage = 7;

  // Controllers and Keys
  ScrollController _scrollController = ScrollController();
  final GlobalKey _tutorialKey = GlobalKey();

  // Video player controllers
  VideoPlayerController? _videoController1;
  VideoPlayerController? _videoController2;




  @override
  void initState() {
    super.initState();
    _initializeVideos();
    _loadTutorialQuestions();

  }

  @override
  void dispose() {
    _videoController1?.dispose();
    _videoController2?.dispose();
    super.dispose();
  }

  void _playVideo(VideoPlayerController? controllerToPlay) {
    setState(() {
      if (_videoController1 != null && _videoController1 != controllerToPlay) {
        _videoController1!.pause();
      }
      if (_videoController2 != null && _videoController2 != controllerToPlay) {
        _videoController2!.pause();
      }
      if (controllerToPlay != null) {
        controllerToPlay.play();
      }
    });
  }

  final List<Map<String, String>> pdfFiles = [
    {
      'name': 'Input Certificate',
      'url': 'assets/Input_Certificate.pdf', // Relative URL for web
    },
    // Add more PDFs as needed
  ];
  Future<void> _initializeVideos() async {
    final storage = FirebaseStorage.instance;
    final gsUrl1 = 'gs://personality-score.appspot.com/Personality Score 3.mov';
    final gsUrl2 = 'gs://personality-score.appspot.com/Personality Score 1.mov'; // Replace with the correct URL if different

    try {
      // Initialize the first video controller
      String downloadUrl1 = await storage.refFromURL(gsUrl1).getDownloadURL();
      _videoController1 = VideoPlayerController.networkUrl(Uri.parse(downloadUrl1))
        ..setLooping(true)
        ..initialize().then((_) {
          setState(() {});
        });

      // Initialize the second video controller
      String downloadUrl2 = await storage.refFromURL(gsUrl2).getDownloadURL();
      _videoController2 = VideoPlayerController.networkUrl(Uri.parse(downloadUrl2))
        ..setLooping(true)
        ..initialize().then((_) {
          setState(() {});
        });
    } catch (e) {
      print('Error loading video: $e');
    }
  }

  Future<void> _loadTutorialQuestions() async {
    // Simulate loading delay
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      appBar: CustomAppBar(title: 'Personality Score'),
      body: SingleChildScrollView(
        controller: _scrollController, // Attach the scroll controller
        child: Column(
          children: [

            SizedBox(height: 350),
            _buildHeaderSection(context, screenHeight, screenWidth),
            SizedBox(height: 350),
            _buildVideoSection1(),
            SizedBox(height: 350),
            _buildPersonalityTypesSection(context, screenHeight, screenWidth),
            SizedBox(height: 350),
            isLoading ? CircularProgressIndicator() : _buildTutorialSection(context),
            SizedBox(height: 350),
            _buildTestimonialSection(), // Add the testimonial section here
            SizedBox(height: 100),
            CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialSection(BuildContext context) {
    return Container(
      key: _tutorialKey, // Add the key here
      child: Column(
        children: [
          SizedBox(height: 40),
          _buildVideoSection2(),
          SizedBox(height: 40),
          _buildQuestionsList(context),
          SizedBox(height: 40),
          _buildNavigationButton(context),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, double screenHeight, double screenWidth) {
    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/background_personality_type.svg',
            fit: BoxFit.cover,
            width: screenWidth,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                SelectableText(
                  "Die 8 Stufen der Persönlichkeitsentwicklung – auf welcher stehst du?",
                  style: TextStyle(
                    fontSize: screenHeight * 0.042,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SelectableText(
                  "Erhalte messerscharfe Klarheit über deinen Entwicklungsstand und erfahre, wie du das nächste Level erreichen kannst.",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCB9935),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.07,
                      vertical: screenHeight * 0.021,
                    ),
                  ),
                  onPressed: () {
                    _scrollToTutorialSection(); // Scroll to the tutorial section
                  },
                  child: Text(
                    'Zum Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.021,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _scrollToTutorialSection() {
    Scrollable.ensureVisible(
      _tutorialKey.currentContext!,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildVideoSection1() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Wieso MUSST du den Personality Score ausfüllen?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _videoController1 != null && _videoController1!.value.isInitialized
              ? LayoutBuilder(
            builder: (context, constraints) {
              double playerWidth = constraints.maxWidth * 0.55;
              return Center(
                child: Column(
                  children: [
                    Container(
                      width: playerWidth,
                      child: AspectRatio(
                        aspectRatio: _videoController1!.value.aspectRatio,
                        child: VideoPlayer(_videoController1!),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _videoController1!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (_videoController1!.value.isPlaying) {
                          _videoController1!.pause();
                        } else {
                          _playVideo(_videoController1);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          )
              : CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildVideoSection2() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Starte Hier",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _videoController2 != null && _videoController2!.value.isInitialized
              ? LayoutBuilder(
            builder: (context, constraints) {
              double playerWidth = constraints.maxWidth * 0.55;
              return Center(
                child: Column(
                  children: [
                    Container(
                      width: playerWidth,
                      child: AspectRatio(
                        aspectRatio: _videoController2!.value.aspectRatio,
                        child: VideoPlayer(_videoController2!),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _videoController2!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (_videoController2!.value.isPlaying) {
                          _videoController2!.pause();
                        } else {
                          _playVideo(_videoController2);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          )
              : CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context) {
    int start = currentPage * questionsPerPage;
    int end = start + questionsPerPage;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
            backgroundColor: Color(0xFFCB9935),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          onPressed: () {
            handleTakeTest(context); // Ensure this function is defined in your helpers
          },
          child: Text(
            'Beginne den Test',
            style: TextStyle(
                color: Colors.white, fontFamily: 'Roboto', fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialSection() {
    PageController _pageController = PageController(viewportFraction: 0.4);
    int selectedIndex = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.all(16.0),
          color: Color(0xFFF7F5EF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Was unsere Nutzer sagen",
                style: TextStyle(
                  fontSize: 28, // Larger font size for the section title
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 360, // Adjust height based on design
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      itemCount: testimonials.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedIndex;
                        return Transform.scale(
                          scale: isSelected ? 1.15 : 0.85,
                          child: _buildTestimonialCard(
                            testimonials[index]['name']!,
                            testimonials[index]['text']!,
                            testimonials[index]['personalityType']!,
                            testimonials[index]['image']!,
                            isSelected,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          if (_pageController.hasClients) {
                            _pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          if (_pageController.hasClients) {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


  Widget _buildTestimonialCard(
      String name,
      String text,
      String personalityType,
      String imagePath, // Add imagePath parameter
      bool isSelected,
      ) {
    return Container(
      width: isSelected ? 100 : 70, // Adjust width based on selection
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(50.0), // Make the image circular
            child: Image.asset(
              imagePath,
              width: isSelected ? 90 : 70, // Adjust image size for selected card
              height: isSelected ? 90 : 70,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSelected ? 20 : 16, // Adjust font size
              fontFamily: 'Roboto',
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            personalityType,
            style: TextStyle(
              fontSize: isSelected ? 18 : 14, // Adjust font size
              fontFamily: 'Roboto',
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSelected ? 16 : 12, // Adjust font size
                fontFamily: 'Roboto',
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }


// Function to fetch image bytes using dio
  Future<Uint8List> _fetchImageBytes(String imageUrl) async {
    try {
      final response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data);
    } catch (e) {
      throw Exception('Failed to fetch image: $e');
    }
  }


  Widget _buildPersonalityTypesSection(BuildContext context, double screenHeight, double screenWidth) {
    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/background_personality_type.svg',
            fit: BoxFit.cover,
            width: screenWidth,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 50, bottom: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SelectableText(
                      "PERSÖNLICHKEITSSTUFEN",
                      style: TextStyle(
                        fontSize: screenHeight * 0.021,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 20),
                    SelectableText(
                      "Verstehe dich selbst und andere ",
                      style: TextStyle(
                        fontSize: screenHeight * 0.056,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 20),
                    SelectableText(
                      "Vom Anonymus zum LifeArtist: Die 8 Stufen symbolisieren die wichtigsten Etappen auf dem Weg, dein Potenzial voll auszuschöpfen. Mit einem fundierten Verständnis des Modells wirst du nicht nur dich selbst, sondern auch andere Menschen viel besser verstehen und einordnen können.",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        fontSize: screenHeight * 0.021,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 70),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCB9935),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                          vertical: screenHeight * 0.021,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/personality_types');
                      },
                      child: Text(
                        'Erfahre mehr',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: screenHeight * 0.021,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AdventurerImage(screenWidth: screenWidth, screenHeight: screenHeight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget for the tilted Adventurer Image with hover effect
class AdventurerImage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  AdventurerImage({required this.screenWidth, required this.screenHeight});

  @override
  _AdventurerImageState createState() => _AdventurerImageState();
}

class _AdventurerImageState extends State<AdventurerImage> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: Transform(
          transform: !isHovered ? Matrix4.identity() : Matrix4.identity()
            ..setEntry(3, 2, 0.000)
            ..rotateY(pi / 1),
          alignment: FractionalOffset.center,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: !isHovered ? widget.screenWidth * 0.4 : widget.screenWidth * 0.5,
            height: !isHovered ? widget.screenHeight * 0.4 : widget.screenHeight * 0.5,
            child: Image.asset('assets/adventurer_front.png'),
          ),
        ),
      ),
    );
  }
}
