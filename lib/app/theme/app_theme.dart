import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTheme {
  static final TextTheme _baseLightTextTheme =
      GoogleFonts.interTextTheme(ThemeData.light().textTheme);
  static final TextTheme _baseDarkTextTheme =
      GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: _baseLightTextTheme,
      primaryColor: const Color(0xFF1E3A5F),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E3A5F),
        onPrimary: Colors.white,

        primaryContainer: Color(0xFFD6E4F7),
        onPrimaryContainer: Color(0xFF0D2240),

        secondary: Color(0xFF2E5B99),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFDCEBFF),
        onSecondaryContainer: Color(0xFF0A2A55),

        surface: Colors.white,
        onSurface: Color(0xFF1A1A1A),
        onSurfaceVariant: Color(0xFF4A4A5A),

        surfaceContainerHighest: Color(0xFFE5E7EB),

        outline: Color(0xFF8A90A0),
        outlineVariant: Color(0xFFBFC4D0),

        error: Color(0xFFB00020),
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _baseLightTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      scaffoldBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xFF1E3A5F)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF1E3A5F);
          }
          return const Color(0xFF8A90A0);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF1E3A5F).withOpacity(0.4);
          }
          return const Color(0xFFBFC4D0);
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: _baseDarkTextTheme,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7EB3F5),
        onPrimary: Color(0xFF0D2240),

        primaryContainer: Color(0xFF1E3A5F),
        onPrimaryContainer: Color(0xFFD6E4F7),

        secondary: Color(0xFF93C5FD),
        onSecondary: Color(0xFF0A2A55),
        secondaryContainer: Color(0xFF1A3560),
        onSecondaryContainer: Color(0xFFDCEBFF),

        surface: Color(0xFF222326),
        onSurface: Color(0xFFE2E2E9),
        onSurfaceVariant: Color(0xFFB0B4C0),

        surfaceContainerHighest: Color(0xFF2A2B2F),

        outline: Color(0xFF6A7080),
        outlineVariant: Color(0xFF3A3D45),

        error: Color(0xFFFF8A80),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _baseDarkTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        shape: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF252629),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1B1E),
      iconTheme: const IconThemeData(color: Color(0xFF7EB3F5)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF7EB3F5);
          }
          return const Color(0xFF6A7080);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF7EB3F5).withOpacity(0.4);
          }
          return const Color(0xFF3A3D45);
        }),
      ),
    );
  }
}