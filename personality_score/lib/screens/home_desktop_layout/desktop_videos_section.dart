// lib/screens/desktop_layout/desktop_videos_section.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../helper_functions/video_helper.dart'; // Where your VideoWidget is

class DesktopVideosSection extends StatefulWidget {
  const DesktopVideosSection({Key? key}) : super(key: key);

  @override
  State<DesktopVideosSection> createState() => _DesktopVideosSectionState();
}

class _DesktopVideosSectionState extends State<DesktopVideosSection> {
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  bool _hasLoaded = false;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    // Prevent multiple loads
    if (_isLoading || _hasLoaded) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storage = FirebaseStorage.instance;
      final gsUrl1 = 'gs://personality-score.appspot.com/Personality Score 3.mov';

      // Get the download URL from Firebase
      final downloadUrl1 = await storage.refFromURL(gsUrl1).getDownloadURL();

      // Create and initialize the VideoPlayerController
      final controller = VideoPlayerController.network(downloadUrl1)
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
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('DesktopVideosSection-VisibilityKey'),
      onVisibilityChanged: (visibilityInfo) {
        // If at least 20% of this widget is visible, load the video
        if (visibilityInfo.visibleFraction > 0.2) {
          _loadVideo();
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    // If we are still fetching the download URL and have no controller, show spinner
    if (_isLoading && _videoController == null) {
      return const Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Hand off to your VideoWidget, which will also show its own CircularProgressIndicator
    // if the controller is not yet initialized.
    return Column(
      children: [
        VideoWidget(
          videoController: _videoController,
          screenHeight: MediaQuery.of(context).size.height * 1.2,
          headerText: "Wieso MUSST du den Personality Score ausfüllen?",
          subHeaderText: "Erfahre es im Video!",
        ),
      ],
    );
  }
}
