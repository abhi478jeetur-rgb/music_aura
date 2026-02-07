import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.electricPurple,
      scaffoldBackgroundColor: AppColors.midnightBlue,
      
      // Text Theme - Outfit for headings, Inter for body text
      textTheme: TextTheme(
        // Display styles (Outfit - Bold and expressive)
        displayLarge: GoogleFonts.outfit(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        
        // Headline styles (Outfit - Strong hierarchy)
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        
        // Title styles (Outfit - Medium weight)
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        
        // Body styles (Inter - Readable and clear)
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
        
        // Label styles (Inter - UI elements)
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.electricPurple,
        secondary: AppColors.neonCyan,
        surface: AppColors.deepViolet.withOpacity(0.5),
        background: AppColors.midnightBlue,
        error: AppColors.hotPink,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.deepViolet,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.neonCyan,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.neonCyan,
        size: 24,
      ),
    );
  }
}
