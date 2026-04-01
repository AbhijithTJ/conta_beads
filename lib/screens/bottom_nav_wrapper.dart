import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_bottom_nav.dart';
import 'home_page/counting_screen.dart';
import 'global_counts/global_counts_screen.dart';
import 'profile/profile_screen.dart';

class BottomNavWrapper extends StatefulWidget {
  final String userEmail;

  const BottomNavWrapper({
    super.key,
    required this.userEmail,
  });

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
    _screens = [
      CountingScreen(userEmail: widget.userEmail),
      GlobalCountsScreen(personalCount: 245, globalCount: 1245000),
      ProfileScreen(userEmail: widget.userEmail),
    ];
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    if (isKeyboardOpen) {
      return true;
    }

    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Press back again to exit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: CommonBottomNav(
          selectedIndex: _selectedIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
