import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SlideInListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const SlideInListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('slide-$index-${child.key}'),
      child: child
          .animate(delay: delay * index)
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
    );
  }
}
