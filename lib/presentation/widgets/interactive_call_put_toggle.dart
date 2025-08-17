import 'package:flutter/material.dart';

class InteractiveCallPutToggle extends StatefulWidget {
  final bool isCall;
  final ValueChanged<bool> onChanged;

  const InteractiveCallPutToggle({
    Key? key,
    required this.isCall,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<InteractiveCallPutToggle> createState() => _InteractiveCallPutToggleState();
}

class _InteractiveCallPutToggleState extends State<InteractiveCallPutToggle> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool callSelected = widget.isCall;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                callSelected
                    ? Colors.greenAccent.withOpacity(0.7)
                    : Colors.redAccent.withOpacity(0.7),
                Colors.purpleAccent.withOpacity(0.4)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (callSelected ? Colors.greenAccent : Colors.redAccent)
                    .withOpacity(0.8),
                blurRadius: 18,
                spreadRadius: 5,
              )
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ToggleButtons(
            fillColor: Colors.white,
            selectedBorderColor: Colors.transparent,
            // splashBorderRadius: BorderRadius.circular(20), // ❌ Removed because not supported
            selectedColor: Colors.black,
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            isSelected: [callSelected, !callSelected],
            onPressed: (index) => widget.onChanged(index == 0),
            constraints: const BoxConstraints(minHeight: 50, minWidth: 110),
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 24),
                  SizedBox(width: 6),
                  Text('Call', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_downward, color: Colors.redAccent, size: 24),
                  SizedBox(width: 6),
                  Text('Put', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
