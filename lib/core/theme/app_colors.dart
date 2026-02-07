import 'package:flutter/material.dart';

class AppColors {
  // Primary Backgrounds
  static const Color deepViolet = Color(0xFF1E1030); // Deep rich violet
  static const Color midnightBlue = Color(0xFF0F172A); // Very dark blue
  
  // Accents
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color hotPink = Color(0xFFFF0080);
  static const Color electricPurple = Color(0xFFBC13FE);
  static const Color neonPurple = Color(0xFF9D00FF);
  static const Color darkPurple = Color(0xFF2E1065);
  
  // Glassmorphism
  static const Color glassWhite = Colors.white;
  static const Color glassBlack = Colors.black;
  
  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  
  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      deepViolet,
      midnightBlue,
    ],
  );
}
