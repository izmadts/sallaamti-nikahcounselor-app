import 'package:flutter/material.dart';

// This whole app IS one module (Nikah Counselor) — unlike the member app's
// per-module theming, there's a single theme derived from the established
// --mm-* brand palette already used by the web matchmaker panel
// (resources/views/components/matchmaker-layout.blade.php).
class MatchmakerTheme {
  static const Color plum = Color(0xFFBE185D);
  static const Color plumDark = Color(0xFF831843);
  static const Color plumLight = Color(0xFFDB2777);
  static const Color gold = Color(0xFFEC4899);
  static const Color goldLight = Color(0xFFF9A8D4);

  // Tier badge colors, matching matchmaker/performance/index.blade.php.
  static const Map<String, Color> tierColors = {
    'nikah_counselor': Color(0xFF0D6B6B),
    'certified_nikah_counselor': Color(0xFF1A6FB8),
    'senior_nikah_counselor': Color(0xFFB8962E),
    'regional_nikah_coordinator': Color(0xFF7A2E8C),
  };

  static const Map<String, String> tierBadges = {
    'nikah_counselor': '🥉',
    'certified_nikah_counselor': '🥈',
    'senior_nikah_counselor': '🥇',
    'regional_nikah_coordinator': '⭐',
  };

  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(seedColor: plum);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFBF7F9),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      // Material 3's TabBar defaults its selected-label color to
      // colorScheme.primary — identical to the AppBar background it sits
      // on via `bottom:` on every screen that uses one (client detail's 5
      // tabs), making the selected tab's label invisible. Match
      // appBarTheme's white foreground explicitly.
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        labelStyle: TextStyle(fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primaryContainer,
        labelStyle: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}
