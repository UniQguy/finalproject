import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// ==================================================
/// 1) Reusable Animate-on-Visible Wrapper
/// ==================================================
/// Wrap ANY widget with [_AnimatedInView] to fade+slide in
/// with optional stagger index for sequencing animations.
class AnimatedInView extends StatefulWidget {
  final Widget child;
  final int index; // for stagger delay in ms (index * 100)
  const AnimatedInView({super.key, required this.child, this.index = 0});

  @override
  State<AnimatedInView> createState() => _AnimatedInViewState();
}

class _AnimatedInViewState extends State<AnimatedInView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _animate() {
    if (!_triggered) {
      _triggered = true;
      Future.delayed(Duration(milliseconds: widget.index * 100), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('inview-${widget.index}-${widget.child.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) _animate();
      },
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}

/// ==================================================
/// 2) Reusable AppGlassyCard (Neon Glass) with bounce tap
/// ==================================================
/// Use instead of any local GlassyCardFancy/GlassyCard for a consistent style.
class AppGlassyCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;

  const AppGlassyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  State<AppGlassyCard> createState() => _AppGlassyCardState();
}

class _AppGlassyCardState extends State<AppGlassyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) => _scaleController.forward(),
      onTapCancel: () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleController,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: widget.borderRadius.resolve(TextDirection.ltr),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
