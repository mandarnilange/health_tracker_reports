import 'package:flutter/material.dart';

/// Semantic colors for the Health Tracker app.
/// Provides consistent color palette for biomarker status and UI elements.
class AppColors {
  AppColors._();

  // ============================================================================
  // BIOMARKER STATUS COLORS
  // ============================================================================

  /// Color for normal/healthy biomarker values
  static const Color normalGreen = Color(0xFF4CAF50);
  static const Color normalGreenLight = Color(0xFF81C784);
  static const Color normalGreenDark = Color(0xFF388E3C);

  /// Color for warning/borderline biomarker values
  static const Color warningYellow = Color(0xFFFFA726);
  static const Color warningYellowLight = Color(0xFFFFB74D);
  static const Color warningYellowDark = Color(0xFFF57C00);

  /// Color for danger/critical biomarker values
  static const Color dangerRed = Color(0xFFEF5350);
  static const Color dangerRedLight = Color(0xFFE57373);
  static const Color dangerRedDark = Color(0xFFD32F2F);

  // ============================================================================
  // LIGHT THEME COLORS
  // ============================================================================

  /// Primary color for light theme - calming blue for health context
  static const Color lightPrimary = Color(0xFF2196F3);
  static const Color lightPrimaryVariant = Color(0xFF1976D2);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);

  /// Secondary color for light theme - complementary teal
  static const Color lightSecondary = Color(0xFF26A69A);
  static const Color lightSecondaryVariant = Color(0xFF00897B);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);

  /// Surface colors for light theme
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightOnSurface = Color(0xFF212121);
  static const Color lightOnSurfaceVariant = Color(0xFF757575);

  /// Background colors for light theme
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightOnBackground = Color(0xFF212121);

  /// Error colors for light theme
  static const Color lightError = dangerRed;
  static const Color lightOnError = Color(0xFFFFFFFF);

  /// Outline colors for light theme
  static const Color lightOutline = Color(0xFFBDBDBD);
  static const Color lightOutlineVariant = Color(0xFFE0E0E0);

  // ============================================================================
  // DARK THEME COLORS
  // ============================================================================

  /// Primary color for dark theme
  static const Color darkPrimary = Color(0xFF64B5F6);
  static const Color darkPrimaryVariant = Color(0xFF42A5F5);
  static const Color darkOnPrimary = Color(0xFF000000);

  /// Secondary color for dark theme
  static const Color darkSecondary = Color(0xFF4DB6AC);
  static const Color darkSecondaryVariant = Color(0xFF26A69A);
  static const Color darkOnSecondary = Color(0xFF000000);

  /// Surface colors for dark theme
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnSurfaceVariant = Color(0xFFBDBDBD);

  /// Background colors for dark theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Color(0xFFE0E0E0);

  /// Error colors for dark theme
  static const Color darkError = dangerRedLight;
  static const Color darkOnError = Color(0xFF000000);

  /// Outline colors for dark theme
  static const Color darkOutline = Color(0xFF616161);
  static const Color darkOutlineVariant = Color(0xFF424242);

  // ============================================================================
  // ADDITIONAL SEMANTIC COLORS
  // ============================================================================

  /// Color for informational messages
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  /// Color for success messages
  static const Color success = normalGreen;
  static const Color successLight = normalGreenLight;
  static const Color successDark = normalGreenDark;

  /// Color for disabled states
  static const Color disabledLight = Color(0xFFBDBDBD);
  static const Color disabledDark = Color(0xFF616161);

  /// Color for dividers
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // ============================================================================
  // CHART COLORS
  // ============================================================================

  /// Colors for trend charts
  static const List<Color> chartColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFFA726), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF5252), // Red
    Color(0xFF26A69A), // Teal
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF78909C), // Blue Grey
  ];

  /// Colors for trend chart gradients
  static const List<Color> chartGradientColors = [
    Color(0x662196F3), // Blue with transparency
    Color(0x004CAF50), // Green with transparency
  ];
}
