import 'dart:math';
import 'package:flutter/material.dart';

class ParallaxDraggableCard extends StatefulWidget {
  final Widget child;
  final double maxTilt; // maximum tilt radians for both axes
  final double scaleOnDrag; // optional scale when dragging

  const ParallaxDraggableCard({
    Key? key,
    required this.child,
    this.maxTilt = 0.05,
    this.scaleOnDrag = 0.98,
  }) : super(key: key);

  @override
  _ParallaxDraggableCardState createState() => _ParallaxDraggableCardState();
}

class _ParallaxDraggableCardState extends State<ParallaxDraggableCard> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _dragging = false;

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
      _tiltX = 0.0;
      _tiltY = 0.0;
      _dragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        if (!_dragging) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            _updateTilt(event.localPosition, renderBox.size);
          }
        }
      },
      onExit: (_) {
        if (!_dragging) {
          _resetTilt();
        }
      },
      child: GestureDetector(
        onPanStart: (details) {
          _dragging = true;
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
        onPanEnd: (_) {
          _dragging = false;
          _resetTilt();
        },
        onPanCancel: () {
          _dragging = false;
          _resetTilt();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_tiltX)
            ..rotateY(_tiltY),
          child: widget.child,
        ),
      ),
    );
  }
}
