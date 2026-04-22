import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../colors/colors.dart';
import '../theme/theme_notifier.dart';

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
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final navBg = isDark ? AppColors.homeBg : const Color(0xFFEDE0ED);
        final iconColor = isDark ? Colors.white : AppColors.homeBg;
        final iconDimColor = isDark ? Colors.white60 : AppColors.homeBg.withOpacity(0.4);
        final btnBg = isDark ? const Color(0xFF8B1A5A) : AppColors.authPurple;

        return CurvedNavigationBar(
          index: selectedIndex,
          height: 65.0,
          items: [
            Icon(Icons.home_rounded, size: 28, color: selectedIndex == 0 ? iconColor : iconDimColor),
            Icon(Icons.public_rounded, size: 28, color: selectedIndex == 1 ? iconColor : iconDimColor),
            Icon(Icons.group_rounded, size: 28, color: selectedIndex == 2 ? iconColor : iconDimColor),
            Icon(Icons.person_rounded, size: 28, color: selectedIndex == 3 ? iconColor : iconDimColor),
          ],
          color: navBg,
          buttonBackgroundColor: btnBg,
          backgroundColor: Colors.white,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          onTap: onTap,
          letIndexChange: (index) => true,
        );
      },
    );
  }
}
