import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final double scale;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    required this.scale,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20 * scale,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurpleAccent,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * scale,
                ),
              ),
              child: const Text('View All'),
            ),
        ],
      ),
    );
  }
}
