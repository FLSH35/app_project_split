// lib/screens/desktop_layout/desktop_videos_section.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

import '../../helper_functions/video_helper.dart';

class DesktopVideosSection extends StatefulWidget {
  const DesktopVideosSection({Key? key}) : super(key: key);

  @override
  State<DesktopVideosSection> createState() => _DesktopVideosSectionState();
}

class _DesktopVideosSectionState extends State<DesktopVideosSection> {
  Future<List<VideoPlayerController>>? _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _loadVideos();
  }

  Future<List<VideoPlayerController>> _loadVideos() async {
    final storage = FirebaseStorage.instance;

    final gsUrl1 = 'gs://personality-score.appspot.com/Personality Score 3.mov';
    final gsUrl2 = 'gs://personality-score.appspot.com/Personality Score 1.mov';

    final List<VideoPlayerController> controllers = [];

    try {
      String downloadUrl1 = await storage.refFromURL(gsUrl1).getDownloadURL();
      final controller1 = VideoPlayerController.networkUrl(Uri.parse(downloadUrl1))
        ..setLooping(true);
      await controller1.initialize();
      controllers.add(controller1);

      String downloadUrl2 = await storage.refFromURL(gsUrl2).getDownloadURL();
      final controller2 = VideoPlayerController.networkUrl(Uri.parse(downloadUrl2))
        ..setLooping(true);
      await controller2.initialize();
      controllers.add(controller2);

      return controllers;
    } catch (e) {
      print('Error loading video: $e');
      return [];
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose all video controllers if loaded
    _videosFuture?.then((controllers) {
      for (var c in controllers) {
        c.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoPlayerController>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Noch kein Video geladen -> Placeholder
          return const Center(
            child: SizedBox(
              height: 200,
              child: CircularProgressIndicator(),
            ),
          );
        }

        final controllers = snapshot.data!;
        if (controllers.isEmpty) {
          return const Text('Videos konnten nicht geladen werden');
        }

        final controller1 = controllers[0];
        final controller2 = controllers.length > 1 ? controllers[1] : null;

        return Column(
          children: [
            VideoWidget(
              videoController: controller1,
              screenHeight: MediaQuery.of(context).size.height * 0.8,
              headerText: "Wieso MUSST du den Personality Score ausfüllen?",
              subHeaderText: "Erfahre es im Video!",
            ),
            const SizedBox(height: 100),
            if (controller2 != null)
              VideoWidget(
                videoController: controller2,
                screenHeight: MediaQuery.of(context).size.height * 0.8,
                headerText: "Starte Hier",
                subHeaderText: "10 Minuten. 120 Fragen. Bis zu deinem Ergebnis!",
              ),
          ],
        );
      },
    );
  }
}
