
// Adventurer Image with Tap Animation
import 'dart:math';

import 'package:flutter/cupertino.dart';


// Widget for the tilted Adventurer Image with hover effect

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
