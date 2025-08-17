import 'package:flutter/material.dart';

class AnimatedInView extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final double offsetY;

  const AnimatedInView({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 100),
    this.offsetY = 30,
  });

  @override
  State<AnimatedInView> createState() => _AnimatedInViewState();
}

class _AnimatedInViewState extends State<AnimatedInView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    Future.delayed(
      Duration(
          milliseconds:
          widget.baseDelay.inMilliseconds + (100 * widget.index)),
          () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final value = _animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * widget.offsetY),
            child: child,
          ),
        );
      },
    );
  }
}
