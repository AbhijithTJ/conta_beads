import 'package:flutter/material.dart';

class ThemeNotifier extends ValueNotifier<bool> {
  ThemeNotifier(super.isDark);

  bool get isDark => value;

  void toggle() => value = !value;
  void setDark(bool dark) => value = dark;
}

// Global singleton
final themeNotifier = ThemeNotifier(true);
