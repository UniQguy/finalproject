import 'package:flutter/material.dart';

class AnimatedGradientWidget extends StatelessWidget {
  final Widget? child;

  const AnimatedGradientWidget({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return _AnimatedGradientBackground(child: child);
  }
}

class _AnimatedGradientBackground extends StatefulWidget {
  final Widget? child;

  const _AnimatedGradientBackground({this.child});

  @override
  State<_AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Alignment> _beginAnimation;
  late final Animation<Alignment> _endAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _beginAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _endAnimation = Tween<Alignment>(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _beginAnimation.value,
            end: _endAnimation.value,
            colors: [
              Colors.deepPurple.shade900,
              Colors.black,
              Colors.blueGrey.shade900,
            ],
          ),
        ),
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
  }
}
