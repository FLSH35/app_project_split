// lib/screens/desktop_layout/desktop_video_section2.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../helper_functions/video_helper.dart'; // Where your VideoWidget is

class DesktopVideoSection2 extends StatefulWidget {
  const DesktopVideoSection2({Key? key}) : super(key: key);

  @override
  State<DesktopVideoSection2> createState() => _DesktopVideoSection2State();
}

class _DesktopVideoSection2State extends State<DesktopVideoSection2> {
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  bool _hasLoaded = false;

  Future<void> _loadVideo() async {
    // Don’t load multiple times
    if (_isLoading || _hasLoaded) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storage = FirebaseStorage.instance;
      final gsUrl2 = 'gs://personality-score.appspot.com/Personality Score 1.mov';

      // Fetch Firebase download URL
      final downloadUrl = await storage.refFromURL(gsUrl2).getDownloadURL();

      // Create and initialize VideoPlayerController
      final controller = VideoPlayerController.network(downloadUrl)
        ..setLooping(true);
      await controller.initialize();

      if (mounted) {
        setState(() {
          _videoController = controller;
          _hasLoaded = true;
        });
      }

      // Optionally auto-play
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
    // Only load when the widget is visible
    return VisibilityDetector(
      key: const Key('desktop-video-section2-visibility-key'),
      onVisibilityChanged: (info) {
        // If more than 20% of the widget is visible on screen, start loading
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
    // You can choose to show a bigger spinner *before* the VideoWidget’s own spinner:
    if (_isLoading && _videoController == null) {
      // Show a spinner while we are fetching the download URL.
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Once we have the controller (or if we’re done loading),
    // hand it off to VideoWidget to handle its own loading UI.
    return VideoWidget(
      videoController: _videoController,
      screenHeight: MediaQuery.of(context).size.height * 1.2,
      headerText: "Starte Hier",
      subHeaderText: "10 Minuten. 120 Fragen. Bis zu deinem Ergebnis!",
    );
  }
}
