import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: forest),
      textTheme: GoogleFonts.dmSansTextTheme(),
      fontFamily: GoogleFonts.dmSans().fontFamily,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0));
}

const eyebrowStyle = TextStyle(
    color: sage, fontSize: 9, letterSpacing: 1.8, fontWeight: FontWeight.w600);
const displayStyle = TextStyle(color: ink, fontFamily: 'Playfair Display', fontSize: 31, height: 1.2);
const sectionStyle = TextStyle(color: ink, fontFamily: 'Playfair Display', fontSize: 25, height: 1.18);
const bodyStyle = TextStyle(color: muted, fontFamily: 'DM Sans', fontSize: 12, height: 1.55);
