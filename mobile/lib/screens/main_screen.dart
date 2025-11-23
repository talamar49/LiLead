import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      body: child,
      floatingActionButton: BreathingFab(
        onPressed: () => context.go('/'),
        color: Theme.of(context).primaryColor,
        child: const Icon(Icons.dashboard, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
