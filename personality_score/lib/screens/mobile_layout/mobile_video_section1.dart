// lib/screens/mobile_layout/mobile_video_section1.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../helper_functions/video_helper.dart'; // Ensure this path is correct

class MobileVideoSection1 extends StatefulWidget {
  const MobileVideoSection1({Key? key}) : super(key: key);

  @override
  _MobileVideoSection1State createState() => _MobileVideoSection1State();
}

class _MobileVideoSection1State extends State<MobileVideoSection1> {
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  bool _hasLoaded = false;

  Future<void> _loadVideo() async {
    if (_isLoading || _hasLoaded) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storage = FirebaseStorage.instance;
      final gsUrl = 'gs://personality-score.appspot.com/PS_3_cut.mp4';

      final downloadUrl = await storage.refFromURL(gsUrl).getDownloadURL();

      final controller = VideoPlayerController.network(downloadUrl)
        ..setLooping(true);
      await controller.initialize();

      if (mounted) {
        setState(() {
          _videoController = controller;
          _hasLoaded = true;
        });
      }

      _videoController?.play();
    } catch (e) {
      debugPrint('Error loading video: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('mobile-video-section1-visibility-key'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) {
          _loadVideo();
        }
      },
      child: Center(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading && _videoController == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return VideoWidget(
      videoController: _videoController,
      screenHeight: MediaQuery.of(context).size.height * 1.2,
      headerText: "Wieso MUSST du den Personality Score ausfüllen?",
      subHeaderText: "Erfahre es im Video!",
    );
  }
}
