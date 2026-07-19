import 'package:flutter/material.dart';

class AppColors {
  // Deep navy / dairy blue as primary
  static const primary = Color(0xFF1A365D);
  static const primaryLight = Color(0xFF2B6CB0);
  
  // Semantic Colors
  static const secondary = Color(0xFF43A047); 
  static const background = Color(0xFFF7FAFC);
  static const surface = Colors.white;
  
  static const textPrimary = Color(0xFF2D3748);
  static const textSecondary = Color(0xFF718096);
  
  // Status Colors
  static const error = Color(0xFFE53E3E); // Red for rejected/spoiled/high severity
  static const warning = Color(0xFFD69E2E); // Amber for pending/warnings
  static const success = Color(0xFF38A169); // Green for accepted/safe/completed
  static const processing = Color(0xFF805AD5); // Purple or indigo for processing
  static const info = Color(0xFF3182CE); 
}
