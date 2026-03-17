import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4351FF); // Vibrant Blue from Figma
  static const Color primaryLight = Color(0xFF6470FF);
  
  // Background Colors
  static const Color background = Color(0xFF0F0F13); // Deep Dark Background
  static const Color surface = Color(0xFF1C1C23); // Slightly lighter for cards
  static const Color surfaceLight = Color(0xFF2C2C35);

  // Status Colors
  static const Color income = Color(0xFF00C853); // Pure Green
  static const Color expense = Color(0xFFFF3D00); // Pure Red
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9EA3AE);
  static const Color textHint = Color(0xFF4E5564);

  // Accents
  static const Color accent = Color(0xFF7C4DFF);
  static const Color divider = Color(0xFF2C2C35);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF6E7AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
