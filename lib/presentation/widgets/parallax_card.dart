import 'package:flutter/material.dart';

class ParallaxCard extends StatefulWidget {
  final Widget child;
  final double maxTilt; // maximum tilt in radians for both axes

  const ParallaxCard({
    Key? key,
    required this.child,
    this.maxTilt = 0.05,
  }) : super(key: key);

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard> {
  double _tiltX = 0;
  double _tiltY = 0;

  // Update tilt angles based on pointer position relative to center
  void _updateTilt(Offset localPosition, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final dx = (localPosition.dx - centerX) / centerX;
    final dy = (localPosition.dy - centerY) / centerY;

    setState(() {
      _tiltX = dy * widget.maxTilt;
      _tiltY = -dx * widget.maxTilt;
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          _updateTilt(event.localPosition, renderBox.size);
        }
      },
      onExit: (_) => _resetTilt(),
      child: GestureDetector(
        onPanStart: (details) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            _updateTilt(renderBox.globalToLocal(details.globalPosition), renderBox.size);
          }
        },
        onPanUpdate: (details) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            _updateTilt(renderBox.globalToLocal(details.globalPosition), renderBox.size);
          }
        },
        onPanEnd: (_) => _resetTilt(),
        onPanCancel: () => _resetTilt(),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective depth
            ..rotateX(_tiltX)
            ..rotateY(_tiltY),
          child: widget.child,
        ),
      ),
    );
  }
}
