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
        final navBg = isDark ? const Color(0xFF22014D) : Colors.white;
        final iconColor = isDark ? Colors.white : const Color(0xFF624294);
        final iconDimColor = isDark
            ? Colors.white.withOpacity(0.45)
            : const Color(0xFF624294).withOpacity(0.35);
        final btnBg = isDark ? AppColors.goldPrimary : const Color(0xFF624294);
        // backgroundColor is the curved area behind the nav — must match page bg
        final curveBg = isDark ? Colors.white : const Color(0xFFF0EBF0);

        return CurvedNavigationBar(
          index: selectedIndex,
          height: 65.0,
          items: [
            Icon(Icons.home_rounded,        size: 26, color: selectedIndex == 0 ? Colors.white : iconDimColor),
            Icon(Icons.public_rounded,      size: 26, color: selectedIndex == 1 ? Colors.white : iconDimColor),
            Icon(Icons.group_rounded,       size: 26, color: selectedIndex == 2 ? Colors.white : iconDimColor),
            Icon(Icons.church_rounded,      size: 26, color: selectedIndex == 3 ? Colors.white : iconDimColor),
            Icon(Icons.menu_book_rounded,   size: 26, color: selectedIndex == 4 ? Colors.white : iconDimColor),
            Icon(Icons.person_rounded,      size: 26, color: selectedIndex == 5 ? Colors.white : iconDimColor),
          ],
          color: navBg,
          buttonBackgroundColor: btnBg,
          backgroundColor: curveBg,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          onTap: onTap,
          letIndexChange: (index) => true,
        );
      },
    );
  }
}
