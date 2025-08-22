import 'package:flutter/material.dart';
import '../widgets/animated_in_view.dart';

class QuickActions extends StatelessWidget {
  final double scale;
  const QuickActions({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.search, 'label': 'Search Stocks', 'route': '/search'},
      {'icon': Icons.notifications, 'label': 'Notifications', 'route': '/notifications'},
      {'icon': Icons.settings, 'label': 'Settings', 'route': '/settings'},
      {'icon': Icons.person, 'label': 'Profile', 'route': '/profile'},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 22 * scale,
      runSpacing: 22 * scale,
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return AnimatedInView(
          index: index,
          child: GestureDetector(
            onTap: () {
              final route = action['route'] as String?;
              if (route != null) {
                Navigator.of(context).pushNamed(route);
              }
            },
            child: Container(
              width: 130 * scale,
              height: 130 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26 * scale),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3A0CA3), Color(0xFF54007E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(156, 39, 176, 0.6),
                    blurRadius: 20,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action['icon'] as IconData,
                    color: Colors.white,
                    size: 48 * scale,
                    shadows: const [
                      Shadow(blurRadius: 12, color: Colors.purpleAccent)
                    ],
                  ),
                  SizedBox(height: 14 * scale),
                  Text(
                    action['label'] as String,
                    style: TextStyle(
                      fontSize: 18 * scale,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: const [
                        Shadow(blurRadius: 14, color: Colors.purpleAccent),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
