import 'package:flutter/material.dart';

class InteractiveCallPutToggle extends StatelessWidget {
  final bool isCall;
  final ValueChanged<bool> onChanged;

  const InteractiveCallPutToggle({
    required this.isCall,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.deepPurpleAccent;
    final inactiveColor = Colors.white24;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggleButton(
            label: 'Call',
            isActive: isCall,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onTap: () => onChanged(true),
          ),
          _buildToggleButton(
            label: 'Put',
            isActive: !isCall,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
