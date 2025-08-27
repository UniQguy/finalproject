import 'package:flutter/material.dart';

class FadeSlideInView extends StatefulWidget {
  final Widget child;
  final int index;

  const FadeSlideInView({Key? key, required this.child, required this.index}) : super(key: key);

  @override
  _FadeSlideInViewState createState() => _FadeSlideInViewState();
}

class _FadeSlideInViewState extends State<FadeSlideInView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 500 + widget.index * 100), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.25), end: Offset.zero).animate(_controller);

    _controller.forward();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
