import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';
import '../theme/theme_notifier.dart';
import '../widgets/common_bottom_nav.dart';
import 'home_page/home_screen.dart';
import 'global_counts/global_counts_screen.dart';
import 'intentions/intentions_screen.dart';
import 'adopt_priest/adopt_priest_screen.dart';
import 'everyday_prayers/everyday_prayers_screen.dart';
import 'profile/profile_screen.dart';

/// Main navigation shell.
/// No userEmail prop — all screens read user data from [UserProvider].
class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressTime;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      GlobalCountsScreen(),
      IntentionsScreen(),
      AdoptPriestScreen(),
      EverydayPrayersScreen(),
      ProfileScreen(),
    ];
    
    // Sync FCM Token with backend silently at startup
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFcmToken());
  }

  Future<void> _syncFcmToken() async {
    try {
      final fcmToken = await NotificationService.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      
      // Stable device identifier logic
      final deviceId = '${Platform.operatingSystem}_stable_id';

      // Silently update FCM token on the backend
      await userProvider.updateFcmToken(fcmToken, deviceId);
      debugPrint("FCM Token synced with backend.");
    } catch (e) {
      debugPrint("Failed to sync FCM token: $e");
    }
  }

  void _onNavTap(int index) => setState(() => _selectedIndex = index);

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (MediaQuery.of(context).viewInsets.bottom != 0) return true;

    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor =
            isDark ? const Color(0xFF22014D) : const Color(0xFFEDE0ED);
        return Consumer<LanguageProvider>(
          builder: (_, languageProvider, __) {
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) async {
                if (didPop) return;
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) SystemNavigator.pop();
              },
              child: Scaffold(
                backgroundColor: bgColor,
                body: IndexedStack(
                  index: _selectedIndex,
                  children: _screens,
                ),
                bottomNavigationBar: CommonBottomNav(
                  selectedIndex: _selectedIndex,
                  onTap: _onNavTap,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
