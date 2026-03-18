import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4351FF); 
  static const Color primaryLight = Color(0xFF6E7AFF);
  
  // Background Colors
  static const Color background = Color(0xFF0F0F13); 
  static const Color surface = Color(0xFF17171F); // Slightly deeper for cards
  static const Color surfaceLight = Color(0xFF22222E);
  static const Color surfaceLighter = Color(0xFF2C2C35);

  // Status Colors
  static const Color income = Color(0xFF2BB673); // Muted Green from Figma
  static const Color expense = Color(0xFFFF5656); // Muted Red from Figma
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9EA3AE);
  static const Color textHint = Color(0xFF4E5564);

  // Accents
  static const Color accent = Color(0xFF7C4DFF);
  static const Color divider = Color(0xFF22222E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF6E7AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGradient = LinearGradient(
    colors: [surface, surface.withOpacity(0.8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
