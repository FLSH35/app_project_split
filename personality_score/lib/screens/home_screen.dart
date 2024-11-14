import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'home_desktop_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'mobile_sidebar.dart';
import 'package:personality_score/helper_functions/questionnaire_helpers.dart';
import 'custom_footer.dart'; // Import for the custom footer
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers and Keys
  ScrollController _scrollController = ScrollController();
  final GlobalKey _tutorialKey = GlobalKey();

  // State variables
  bool isLoading = true;
  int currentPage = 0;
  int questionsPerPage = 7;
  List<String> tutorialQuestions = [
    'Mit dem Schieberegler kann ich 10 verschiedene Stufen einstellen.',
    'Die Test-Fragen beantworte ich schnell, ohne lange nachzudenken.',
    'Ich antworte ehrlich und gewissenhaft.',
  ];
  Map<int, int> answers = {};

  // Video player controllers
  VideoPlayerController? _videoController1;
  VideoPlayerController? _videoController2;

  @override
  void initState() {
    super.initState();
    _initializeVideos();
    _loadTutorialQuestions();
  }

  Future<void> _initializeVideos() async {
    final storage = FirebaseStorage.instance;
    final gsUrl1 = 'gs://personality-score.appspot.com/Personality Score 3.mov';
    final gsUrl2 = 'gs://personality-score.appspot.com/Personality Score 1.mov';

    try {
      // Load the first video
      String downloadUrl1 = await storage.refFromURL(gsUrl1).getDownloadURL();
      _videoController1 = VideoPlayerController.networkUrl(Uri.parse(downloadUrl1))
        ..setLooping(true)
        ..initialize().then((_) {
          setState(() {});
        });

      // Load the second video
      String downloadUrl2 = await storage.refFromURL(gsUrl2).getDownloadURL();
      _videoController2 = VideoPlayerController.networkUrl(Uri.parse(downloadUrl2))
        ..setLooping(true)
        ..initialize().then((_) {
          setState(() {});
        });
    } catch (e) {
      print('Error loading videos: $e');
    }
  }

  Future<void> _loadTutorialQuestions() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _videoController1?.dispose();
    _videoController2?.dispose();
    super.dispose();
  }

  // Mobile AppBar (grey background, button for right drawer)
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('PERSONALITY SCORE'),
      backgroundColor: Color(0xFFF7F5EF),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFEDE8DB),
      endDrawer: MobileSidebar(),
      appBar: getValueForScreenType<bool>(
        context: context,
        mobile: false,
        desktop: true,
      )
          ? null
          : _buildAppBar(context),
      body: ScreenTypeLayout(
        mobile: _buildMobileLayout(screenHeight, screenWidth),
        desktop: DesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout(double screenHeight, double screenWidth) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          SizedBox(height: 200),
          _buildHeaderSection(context, screenHeight, screenWidth),
          SizedBox(height: 200),
          _buildVideoSection1(),
          SizedBox(height: 200),
          _buildPersonalityTypesSection(context, screenHeight, screenWidth),
          SizedBox(height: 200),
          isLoading ? CircularProgressIndicator() : _buildTutorialSection(context),
          SizedBox(height: 200),
          CustomFooter(),
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
                    fontSize: screenHeight * 0.036,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                SelectableText(
                  "Erhalte messerscharfe Klarheit über deinen Entwicklungsstand und erfahre, wie du das nächste Level erreichen kannst.",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
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
                    _scrollToTutorialSection();
                  },
                  child: Text(
                    'Beginne den Test',
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
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          _videoController1 != null && _videoController1!.value.isInitialized
              ? Center(
            child: AspectRatio(
              aspectRatio: _videoController1!.value.aspectRatio,
              child: VideoPlayer(_videoController1!),
            ),
          )
              : CircularProgressIndicator(),
          IconButton(
            icon: Icon(
              _videoController1?.value.isPlaying ?? false ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              if (_videoController1?.value.isPlaying ?? false) {
                _videoController1?.pause();
              } else {
                _videoController1?.play();
              }
            },
          ),
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
            horizontal: MediaQuery.of(context).size.width / 10,
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
                  Text(
                    'NEIN',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'EHER NEIN',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'NEUTRAL',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'EHER JA',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
        backgroundColor: Color(0xFFCB9935),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      onPressed: () {
        handleTakeTest(context);
      },
      child: Text(
        'Beginne den Test',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 18,
        ),
      ),
    );
  }

  // Personality types section
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "PERSÖNLICHKEITSSTUFEN",
                style: TextStyle(
                  fontSize: screenHeight * 0.021,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Verstehe dich selbst und andere",
                style: TextStyle(
                  fontSize: screenHeight * 0.056,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.07,
                    vertical: screenHeight * 0.021,
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
              SizedBox(height: 40),
              SizedBox(
                width: screenWidth * 0.7,
                height: screenHeight * 0.35,
                child: Image.asset('assets/adventurer_front.png'),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildTutorialSection(BuildContext context) {
    return Container(
      key: _tutorialKey,
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
              ? Center(
            child: AspectRatio(
              aspectRatio: _videoController2!.value.aspectRatio,
              child: VideoPlayer(_videoController2!),
            ),
          )
              : CircularProgressIndicator(),
          IconButton(
            icon: Icon(
              _videoController2?.value.isPlaying ?? false ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              if (_videoController2?.value.isPlaying ?? false) {
                _videoController2?.pause();
              } else {
                _videoController2?.play();
              }
            },
          ),
        ],
      ),
    );
  }
}
