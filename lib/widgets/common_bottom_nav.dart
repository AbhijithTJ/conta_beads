import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../colors/colors.dart';

class CommonBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CommonBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selectedIndex,
      height: 65.0,
      items: [
        Icon(
          Icons.home_rounded,
          size: 30,
          color: selectedIndex == 0 ? Colors.white : AppColors.textSecondary,
        ),
        Icon(
          Icons.person_rounded,
          size: 30,
          color: selectedIndex == 1 ? Colors.white : AppColors.textSecondary,
        ),
      ],
      color: Colors.white,
      buttonBackgroundColor: AppColors.goldPrimary,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 600),
      onTap: onTap,
      letIndexChange: (index) => true,
    );
  }
}
