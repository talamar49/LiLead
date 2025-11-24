import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final num? animatedValue;
  final bool isPercentage;
  final VoidCallback? onTap;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.animatedValue,
    this.isPercentage = false,
    this.onTap,
  });

  @override
  State<DashboardStatsCard> createState() => _DashboardStatsCardState();
}

class _DashboardStatsCardState extends State<DashboardStatsCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? (isDark ? const Color(0xFF3A3A3C) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(_isPressed ? 0.02 : 0.05),
                  blurRadius: _isPressed ? 5 : 10,
                  offset: Offset(0, _isPressed ? 2 : 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 24)
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: 2000.ms,
                      curve: Curves.easeInOut,
                    ),
              ),
              const Spacer(),
              widget.animatedValue != null
                  ? Text(
                      widget.value,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ).animate().custom(
                      duration: 1500.ms,
                      curve: Curves.easeOutExpo,
                      builder: (context, value, child) {
                        final animatedVal = widget.animatedValue!.toDouble() * value;
                        final displayValue = widget.isPercentage
                            ? '${animatedVal.toStringAsFixed(1)}%'
                            : animatedVal.toInt().toString();
                        return Text(
                          displayValue,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        );
                      },
                    )
                  : Text(
                      widget.value,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
