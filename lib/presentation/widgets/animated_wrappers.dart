import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Widget that fades and slides in when it becomes visible.
/// Supports optional staggered animation delay via `index`.
class AnimatedInView extends StatefulWidget {
  final Widget child;
  final int index; // stagger delay multiplier; each unit equals 100ms

  const AnimatedInView({
    super.key,
    required this.child,
    this.index = 0,
  });

  @override
  State<AnimatedInView> createState() => _AnimatedInViewState();
}

class _AnimatedInViewState extends State<AnimatedInView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    final curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _fadeAnimation = curvedAnimation;
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // Starts slightly below, slides up
      end: Offset.zero,
    ).animate(curvedAnimation);
  }

  void _startAnimation() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      Future.delayed(Duration(milliseconds: widget.index * 100), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('animated-inview-${widget.index}-${widget.child.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) {
          _startAnimation();
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
