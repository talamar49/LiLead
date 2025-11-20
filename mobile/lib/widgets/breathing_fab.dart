
import 'package:flutter/material.dart';

class BreathingFab extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;

  const BreathingFab({
    super.key,
    required this.onPressed,
    required this.child,
    required this.color,
  });

  @override
  State<BreathingFab> createState() => _BreathingFabState();
}

class _BreathingFabState extends State<BreathingFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: _shadowAnimation.value,
                spreadRadius: _shadowAnimation.value / 2,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: widget.color,
              shape: const CircleBorder(),
              elevation: 0, // Handle elevation via shadow
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
