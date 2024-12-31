// lib/screens/desktop_layout/desktop_videos_section.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

import '../../helper_functions/video_helper.dart';

class DesktopVideoSection2 extends StatefulWidget {
  const DesktopVideoSection2({Key? key}) : super(key: key);

  @override
  State<DesktopVideoSection2> createState() => _DesktopVideosSectionState();
}

class _DesktopVideosSectionState extends State<DesktopVideoSection2> {
  Future<List<VideoPlayerController>>? _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _loadVideos();
  }

  Future<List<VideoPlayerController>> _loadVideos() async {
    final storage = FirebaseStorage.instance;

    final gsUrl2 = 'gs://personality-score.appspot.com/Personality Score 1.mov';

    final List<VideoPlayerController> controllers = [];

    try {

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

        final controller2 = controllers[0];

        return VideoWidget(
                videoController: controller2,
                screenHeight: MediaQuery.of(context).size.height * 1.5,
                headerText: "Starte Hier",
                subHeaderText: "10 Minuten. 120 Fragen. Bis zu deinem Ergebnis!",
              );

      },
    );
  }
}
