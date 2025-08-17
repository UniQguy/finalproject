import 'package:flutter/material.dart';

class AnimatedGradientWidget extends StatefulWidget {
  const AnimatedGradientWidget({super.key});

  @override
  State<AnimatedGradientWidget> createState() => _AnimatedGradientWidgetState();
}

class _AnimatedGradientWidgetState extends State<AnimatedGradientWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _beginAnimation;
  late Animation<Alignment> _endAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);

    _beginAnimation = Tween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _endAnimation = Tween(
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
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _beginAnimation.value,
            end: _endAnimation.value,
            colors: [
              Colors.deepPurple.shade900,
              Colors.black,
              Colors.blueGrey.shade900
            ],
          ),
        ),
      ),
    );
  }
}
