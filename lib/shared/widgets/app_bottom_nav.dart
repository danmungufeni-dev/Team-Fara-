import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.secondaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppColors.primaryContainer),
            label: context.tr('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map, color: AppColors.primaryContainer),
            label: context.tr('explore'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.lock_clock_outlined),
            selectedIcon: const Icon(Icons.lock_clock, color: AppColors.primaryContainer),
            label: context.tr('requests'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.volunteer_activism_outlined),
            selectedIcon: const Icon(Icons.volunteer_activism, color: AppColors.primaryContainer),
            label: context.tr('donate'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppColors.primaryContainer),
            label: context.tr('profile'),
          ),
        ],
      ),
    );
  }
}
