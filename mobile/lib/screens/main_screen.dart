import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/breathing_fab.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).uri.path;
    
    int getCurrentIndex() {
      if (location == '/new-leads') return 0;
      if (location == '/follow-up') return 1;
      if (location == '/') return 2;
      if (location == '/closed') return 3;
      if (location == '/not-relevant') return 4;
      return 2; // Default to dashboard
    }

    final currentIndex = getCurrentIndex();

    Color getItemColor(int index) {
      return currentIndex == index ? Theme.of(context).primaryColor : Colors.grey;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          // Visual separator
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: BreathingFab(
        onPressed: () => context.go('/'),
        color: Theme.of(context).primaryColor,
        child: const Icon(Icons.dashboard, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          elevation: 0,
          child: SizedBox(
            height: 60,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left side
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      context,
                      icon: CupertinoIcons.flame_fill,
                      label: l10n.newLeads,
                      isSelected: currentIndex == 0,
                      onTap: () => context.go('/new-leads'),
                    ),
                    _buildNavItem(
                      context,
                      icon: CupertinoIcons.clock_fill,
                      label: l10n.followUp,
                      isSelected: currentIndex == 1,
                      onTap: () => context.go('/follow-up'),
                    ),
                  ],
                ),
              ),
              // Space for FAB
              const SizedBox(width: 48),
              // Right side
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      context,
                      icon: CupertinoIcons.number_square_fill,
                      label: l10n.closed,
                      isSelected: currentIndex == 3,
                      onTap: () => context.go('/closed'),
                    ),
                    _buildNavItem(
                      context,
                      icon: CupertinoIcons.nosign,
                      label: l10n.notRelevant ?? 'Not Relevant',
                      isSelected: currentIndex == 4,
                      onTap: () => context.go('/not-relevant'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(icon, color: color, size: 28)
                  .animate(
                    target: isSelected ? 1 : 0,
                  )
                  .shake(
                    duration: 400.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
