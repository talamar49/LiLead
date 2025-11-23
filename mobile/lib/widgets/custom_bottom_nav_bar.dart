import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final bool showDashboard;
  final String dashboardLabel;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.dashboardLabel,
    this.activeColor = const Color(0xFF007AFF),
    this.inactiveColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.showDashboard = false,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _grooveController;
  late AnimationController _breathingController;
  late Animation<double> _grooveAnimation;
  late Animation<double> _breathingScale;
  late Animation<double> _breathingShadow;
  
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Groove slide animation
    _grooveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _grooveAnimation = CurvedAnimation(
      parent: _grooveController,
      curve: Curves.easeInOutCubic,
    );

    // Breathing animation for dashboard
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _breathingScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _breathingShadow = Tween<double>(
      begin: 6.0,
      end: 14.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _grooveController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _grooveController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  double _getGroovePosition(int index, double width) {
    final itemCount = widget.items.length;
    final spacing = width / (itemCount + 1);
    
    // Calculate positions for left items (0, 1)
    if (index < 2) {
      return spacing * (index + 1);
    }
    // Calculate positions for right items (2, 3)
    else {
      return spacing * (index + 2);
    }
  }

  double _getDashboardPosition(double width) {
    return width / 2;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? const Color(0xFF1C1C1E) 
        : widget.backgroundColor;
    
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Navigation bar with notch
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _NavBarPainter(
                backgroundColor: backgroundColor,
                shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                isDark: isDark,
              ),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Left items
                    ...widget.items.sublist(0, 2).asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildNavItem(
                        item,
                        index,
                        widget.currentIndex == index && !widget.showDashboard,
                      );
                    }),
                    
                    // Spacer for center button
                    const SizedBox(width: 90),
                    
                    // Right items
                    ...widget.items.sublist(2).asMap().entries.map((entry) {
                      final index = entry.key + 2;
                      final item = entry.value;
                      return _buildNavItem(
                        item,
                        index,
                        widget.currentIndex == index && !widget.showDashboard,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          
          // Dashboard button (elevated in the center)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildDashboardButton(),
            ),
          ),
          
          // Animated groove indicator (only for non-dashboard items)
          if (!widget.showDashboard)
            AnimatedBuilder(
              animation: _grooveAnimation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    
                    double startPos;
                    double endPos;
                    
                    // Animating between items or from dashboard
                    startPos = _previousIndex == -1 
                        ? _getDashboardPosition(width)
                        : _getGroovePosition(_previousIndex, width);
                    endPos = _getGroovePosition(widget.currentIndex, width);
                    
                    final currentPos = startPos + 
                        (endPos - startPos) * _grooveAnimation.value;
                    
                    return Positioned(
                      left: currentPos - 28,
                      bottom: 66,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 4 * math.sin(value * math.pi)),
                            child: Container(
                              width: 56,
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.activeColor.withOpacity(0.3),
                                    widget.activeColor,
                                    widget.activeColor.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.activeColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavBarItem item, int index, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () => widget.onTap(index),
        splashColor: widget.activeColor.withOpacity(0.1),
        highlightColor: widget.activeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: isActive ? 1.1 : 1.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      item.icon,
                      size: 26,
                      color: isActive ? widget.activeColor : widget.inactiveColor,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? widget.activeColor : widget.inactiveColor,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Outer shadow for elevation
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Breathing glow effect
              if (widget.showDashboard)
                Container(
                  width: 76 * _breathingScale.value,
                  height: 76 * _breathingScale.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.activeColor.withOpacity(0.5),
                        blurRadius: _breathingShadow.value * 1.5,
                        spreadRadius: _breathingShadow.value / 3,
                      ),
                    ],
                  ),
                ),
              
              // Main button with gradient
              Transform.scale(
                scale: widget.showDashboard ? _breathingScale.value : 1.0,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.activeColor.withOpacity(0.9),
                        widget.activeColor,
                        widget.activeColor.withOpacity(0.95),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.activeColor.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onTap(-1),
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      child: Container(
                        alignment: Alignment.center,
                        child: Icon(
                          CupertinoIcons.square_grid_2x2_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom painter for the navigation bar with notch
class _NavBarPainter extends CustomPainter {
  final Color backgroundColor;
  final Color shadowColor;
  final bool isDark;

  _NavBarPainter({
    required this.backgroundColor,
    required this.shadowColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    
    // Start from bottom left
    path.moveTo(0, size.height);
    
    // Left side going up
    path.lineTo(0, 0);
    
    // Top edge until notch
    final centerX = size.width / 2;
    final notchRadius = 44.0; // Increased for larger button
    final controlPointOffset = 22.0;
    
    // Go to start of notch curve
    path.lineTo(centerX - notchRadius - 24, 0);
    
    // Create smooth notch curve
    path.quadraticBezierTo(
      centerX - notchRadius - controlPointOffset, 0,
      centerX - notchRadius, controlPointOffset,
    );
    
    path.quadraticBezierTo(
      centerX - notchRadius / 2, notchRadius - 4,
      centerX, notchRadius + 2,
    );
    
    path.quadraticBezierTo(
      centerX + notchRadius / 2, notchRadius - 4,
      centerX + notchRadius, controlPointOffset,
    );
    
    path.quadraticBezierTo(
      centerX + notchRadius + controlPointOffset, 0,
      centerX + notchRadius + 24, 0,
    );
    
    // Continue to right side
    path.lineTo(size.width, 0);
    
    // Right side going down
    path.lineTo(size.width, size.height);
    
    // Bottom edge
    path.close();

    // Draw shadow
    canvas.drawPath(path, shadowPaint);
    
    // Draw main bar
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.isDark != isDark;
  }
}

class NavBarItem {
  final IconData icon;
  final String label;

  const NavBarItem({
    required this.icon,
    required this.label,
  });
}
