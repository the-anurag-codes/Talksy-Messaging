import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0084FF);
  static const Color primaryLight = Color(0xFF00C6FF);
  static const Color primaryDark = Color(0xFF0056B3);

  static const Color secondary = Color(0xFF44BBA4);
  static const Color error = Color(0xFFE94560);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color divider = Color(0xFFDFE6E9);

  // Message colors
  static const Color sentMessageBg = Color(0xFF0084FF);
  static const Color receivedMessageBg = Color(0xFFE4E6EB);
  static const Color sentMessageText = Colors.white;
  static const Color receivedMessageText = Color(0xFF050505);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0084FF), Color(0xFF00C6FF)],
  );

  static const LinearGradient primaryGradientReverse = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C6FF), Color(0xFF0084FF)],
  );

  static const LinearGradient primaryGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0084FF), Color(0xFF00C6FF)],
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0084FF), Color(0xFF00C6FF)],
  );

  // Gradient with opacity
  static LinearGradient primaryGradientWithOpacity(double opacity) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0084FF).withValues(alpha: opacity),
        Color(0xFF00C6FF).withValues(alpha: opacity),
      ],
    );
  }

  // Subtle gradient for backgrounds
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
  );

  // Unread badge gradient
  static const LinearGradient badgeGradient = LinearGradient(
    colors: [Color(0xFF0084FF), Color(0xFF00A8FF)],
  );

  // Shadow colors
  static Color primaryShadow = const Color(0xFF0084FF).withValues(alpha: 0.2);
  static Color cardShadow = Colors.black.withValues(alpha: 0.05);
}
