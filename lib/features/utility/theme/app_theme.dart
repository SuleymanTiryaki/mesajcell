import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const/constant_color.dart';

final class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ConstColor.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: ConstColor.scaffold,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: ConstColor.appBarBackground,
          foregroundColor: ConstColor.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ConstColor.black,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ConstColor.searchFieldBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          hintStyle: TextStyle(
            fontFamily: GoogleFonts.inter().fontFamily,
            color: ConstColor.grey500,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ConstColor.primary, width: 1.5),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ConstColor.primary,
          foregroundColor: ConstColor.white,
          elevation: 4,
        ),
        dividerTheme: const DividerThemeData(
          color: ConstColor.divider,
          thickness: 1,
          space: 1,
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: ConstColor.black,
          ),
          subtitleTextStyle: GoogleFonts.inter(
            fontSize: 13,
            color: ConstColor.grey600,
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ConstColor.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: ConstColor.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ConstColor.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          hintStyle: TextStyle(
            fontFamily: GoogleFonts.inter().fontFamily,
            color: const Color(0xFF888888),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ConstColor.primary, width: 1.5),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ConstColor.primary,
          foregroundColor: ConstColor.white,
          elevation: 4,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2C2C2C),
          thickness: 1,
          space: 1,
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: ConstColor.white,
          ),
          subtitleTextStyle: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF888888),
          ),
        ),
      );
}
