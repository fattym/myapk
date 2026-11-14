import 'package:flutter/material.dart';
import '../theme/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.subtlePurple,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color:
                selected ? AppColors.primaryPurple : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color:
                selected ? AppColors.primaryPurple : AppColors.textSecondary,
          );
        }),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.dividerColor)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: 'Categories'),
            NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Catalog'),
            NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: 'Schools'),
          ],
        ),
      ),
    );
  }
}
