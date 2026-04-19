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
        Icon(Icons.home_rounded, size: 28, color: selectedIndex == 0 ? Colors.white : Colors.white60),
        Icon(Icons.public_rounded, size: 28, color: selectedIndex == 1 ? Colors.white : Colors.white60),
        Icon(Icons.group_rounded, size: 28, color: selectedIndex == 2 ? Colors.white : Colors.white60),
        Icon(Icons.person_rounded, size: 28, color: selectedIndex == 3 ? Colors.white : Colors.white60),
      ],
      color: AppColors.homeBg,
      buttonBackgroundColor: const Color(0xFF8B1A5A),
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 600),
      onTap: onTap,
      letIndexChange: (index) => true,
    );
  }
}
