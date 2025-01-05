import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final VideoPlayerController? videoController;
  final double screenHeight;
  final String headerText;
  final String subHeaderText;


  const VideoWidget({
    Key? key,
    required this.videoController,
    required this.screenHeight,
    required this.headerText,
    required this.subHeaderText,
  }) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  bool _hasStartedPlaying = false;

  /// Wir halten die aktuelle Lautstärke (zwischen 0.0 und 1.0) im State
  late double _volume;

  /// Steuert die Sichtbarkeit des Lautstärke-Sliders beim Hovern.
  bool _showVolumeSlider = false;



  @override
  void initState() {
    super.initState();

    widget.videoController?.addListener(_updateState);

    // Initialen Lautstärke-Wert setzen
    _volume = 1;
    widget.videoController?.setVolume(_volume);
  }

  @override
  void dispose() {
    widget.videoController?.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Hilfsfunktion, um ein [Duration]-Objekt als mm:ss oder hh:mm:ss darzustellen
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      // Falls das Video länger als eine Stunde dauert
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      // Falls das Video kürzer als eine Stunde ist
      return "${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.videoController;
    final currentPosition = controller?.value.position ?? Duration.zero;
    final totalDuration = controller?.value.duration ?? Duration.zero;

    double videoHeight = widget.screenHeight * 0.4; // 40% der Bildschirmhöhe
    double videoWidth = (controller != null && controller.value.isInitialized)
        ? videoHeight * controller.value.aspectRatio
        : 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SelectableText(
            widget.headerText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SelectableText(
            widget.subHeaderText,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Roboto',
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // -------------------------------------------------
          // Video + Loading
          // -------------------------------------------------
          controller == null || !controller.value.isInitialized
              ? const Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          )
              : Center(
            child: Column(
              children: [
                Container(
                  height: videoHeight,
                  width: videoWidth,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                      if (!_hasStartedPlaying)
                        Image.asset(
                          'assets/thumbnail.png',
                          fit: BoxFit.cover,
                          width: videoWidth,
                          height: videoHeight,
                        ),
                      if (!_hasStartedPlaying)
                        Icon(
                          Icons.play_circle_filled,
                          size: 64,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                              if (!_hasStartedPlaying) {
                                setState(() {
                                  _hasStartedPlaying = true;
                                });
                              }
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // -------------------------------------------------
                // Slider für den Videofortschritt (horizontal)
                // -------------------------------------------------
                SizedBox(
                  width: videoWidth,
                  child: Slider(
                    value: currentPosition.inMilliseconds
                        .toDouble()
                        .clamp(0, totalDuration.inMilliseconds.toDouble()),
                    min: 0,
                    max: totalDuration.inMilliseconds.toDouble(),
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    onChanged: (newValue) {
                      final position =
                      Duration(milliseconds: newValue.toInt());
                      controller.seekTo(position);
                    },
                  ),
                ),
                  // ----------------------------------------
                  // Steuer-Zeile
                  // ----------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play/Pause-Button
                      IconButton(
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () {
                          setState(() {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                              if (!_hasStartedPlaying) {
                                _hasStartedPlaying = true;
                              }
                            }
                          });
                        },
                      ),

                      const SizedBox(width: 16),

                      // ----------------------------------------
                      // Lautstärke-Icon + nur beim Hover
                      // ----------------------------------------
                      MouseRegion(
                        onEnter: (_) {
                          setState(() => _showVolumeSlider = true);
                        },
                        onExit: (_) {
                          setState(() => _showVolumeSlider = false);
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.volume_up),

                            // Zeige den horizontalen Slider NUR beim Hover
                            if (_showVolumeSlider) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: Colors.black,
                                    inactiveTrackColor: Colors.grey,
                                    thumbColor: Colors.black,
                                    trackHeight: 2,
                                  ),
                                  child: Slider(
                                    value: _volume,
                                    min: 0,
                                    max: 1,
                                    onChanged: (value) {
                                      setState(() {
                                        _volume = value;
                                      });
                                      controller.setVolume(_volume);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Zeitangabe
                      Text(
                        '${_formatDuration(currentPosition)} / ${_formatDuration(totalDuration)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
