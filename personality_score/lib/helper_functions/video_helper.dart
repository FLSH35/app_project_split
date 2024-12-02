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

  @override
  void initState() {
    super.initState();
    widget.videoController?.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.videoController?.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    // No need to set _hasStartedPlaying back to false
    // This method can be used for additional state updates if needed
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double videoHeight = widget.screenHeight * 0.4; // 40% of the screen height
    double videoWidth = widget.videoController != null &&
        widget.videoController!.value.isInitialized
        ? videoHeight * widget.videoController!.value.aspectRatio
        : 0; // Default to 0 width if not initialized

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SelectableText(
            widget.headerText,
            style: TextStyle(
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
          SizedBox(height: 20),
          widget.videoController == null ||
              !widget.videoController!.value.isInitialized
              ? Center(
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
                        aspectRatio:
                        widget.videoController!.value.aspectRatio,
                        child: VideoPlayer(widget.videoController!),
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
                            if (widget.videoController!.value.isPlaying) {
                              widget.videoController!.pause();
                            } else {
                              widget.videoController!.play();
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
                // Video Progress Bar
                Container(
                  width: videoWidth, // Match the width of the video
                  child: VideoProgressIndicator(
                    widget.videoController!,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Colors.blue,
                      backgroundColor: Colors.grey,
                      bufferedColor: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
