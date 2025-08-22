import 'package:flutter/material.dart';

/// Widget that animates its child into view with fade and slide transitions.
/// Each instance starts its animation after a delay proportional to `index`.
class AnimatedInView extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedInView({
    required this.child,
    required this.index,
    super.key,
  });

  @override
  State<AnimatedInView> createState() => _AnimatedInViewState();
}

class _AnimatedInViewState extends State<AnimatedInView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 100),
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),  // Slight slide from right
      end: Offset.zero,
    ).animate(curve);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);

    // Staggered animation start based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
