// lib/widgets/lazy_load_image.dart
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LazyLoadImage extends StatefulWidget {
  final String assetPath;
  final BoxFit fit;
  final double? height;
  final double? width;

  const LazyLoadImage({
    Key? key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  _LazyLoadImageState createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  bool _isVisible = false;
  bool _hasLoaded = false;

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_hasLoaded && info.visibleFraction > 0) {
      setState(() {
        _isVisible = true;
        _hasLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('lazy-load-image-${widget.assetPath}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: _isVisible
          ? Image.asset(
        widget.assetPath,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
      )
          : SizedBox(
        height: widget.height ?? 200, // Placeholderhöhe
        width: widget.width ?? double.infinity,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
