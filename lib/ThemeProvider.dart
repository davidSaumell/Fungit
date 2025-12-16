import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static const Color baseLight = Color(0xFFF2EDE4);
  static const Color baseDark = Color(0xFF3A3A3C);
  static const Color accentRed = Color(0xFFD91515);
  static const Color accentGreen = Color(0xFF2E5E3A);

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('es');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  Color get userMessageColor => _themeMode == ThemeMode.dark ? Colors.grey[700]! : Colors.grey[300]!;
  Color get botMessageColor => _themeMode == ThemeMode.dark ? Colors.green[800]! : Colors.green[100]!;
  Color get inputColor => _themeMode == ThemeMode.dark ? Colors.grey[850]! : Colors.white;

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: baseLight,
    primaryColor: baseDark,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: accentGreen.withOpacity(0.9),
      selectedItemColor: baseLight,
      unselectedItemColor: baseLight.withOpacity(0.6),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: baseDark,
      foregroundColor: baseLight,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: accentGreen,
      primary: baseDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentRed,
        foregroundColor: baseLight,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: baseDark,
    primaryColor: baseLight,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: accentGreen.withOpacity(0.9),
      selectedItemColor: baseLight,
      unselectedItemColor: baseLight.withOpacity(0.6),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: baseLight,
      foregroundColor: baseDark,
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
    ).copyWith(secondary: accentGreen, primary: baseLight),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentRed,
        foregroundColor: baseLight,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
