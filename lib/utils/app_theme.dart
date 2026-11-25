import 'package:flutter/material.dart';

class AppTheme {
  // Palet dark mode dengan aksen soft blue
  static const Color latarBelakang = Color(0xFF0D1117);
  static const Color permukaanKartu = Color(0xFF161B22);
  static const Color permukaanElevasi = Color(0xFF1F2630);
  static const Color softBlue = Color(0xFF7CC6FE);
  static const Color softBlueRedup = Color(0xFF3A6EA5);
  static const Color teksUtama = Color(0xFFE6EDF3);
  static const Color teksSekunder = Color(0xFF8B949E);
  static const Color garisBatas = Color(0xFF30363D);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: latarBelakang,
      colorScheme: const ColorScheme.dark(
        primary: softBlue,
        onPrimary: Color(0xFF08121E),
        secondary: softBlueRedup,
        onSecondary: teksUtama,
        surface: permukaanKartu,
        onSurface: teksUtama,
        outline: garisBatas,
      ),
      cardTheme: CardThemeData(
        color: permukaanKartu,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: garisBatas),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: latarBelakang,
        foregroundColor: teksUtama,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: softBlue,
        foregroundColor: Color(0xFF08121E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: permukaanElevasi,
        hintStyle: const TextStyle(color: teksSekunder),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: garisBatas),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: softBlue, width: 1.5),
        ),
      ),
    );
  }
}
