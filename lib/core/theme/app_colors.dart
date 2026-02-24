import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color taiChiGreen = Color(0xFF2E7D32);
  static const Color taiChiGreenLight = Color(0xFF66BB6A);
  static const Color earthyBrown = Color(0xFF8D6E63);
  static const Color earthyBrownLight = Color(0xFFBCAAA4);
  static const Color calmBlue = Color(0xFF1976D2);
  static const Color calmBlueLight = Color(0xFF64B5F6);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Error Colors
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);

  // Success Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF66BB6A);

  // Warning Colors
  static const Color warning = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFFFB74D);

  // Premium Colors
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumGoldLight = Color(0xFFFFF176);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    taiChiGreen,
    taiChiGreenLight,
  ];

  static const List<Color> breathingGradient = [
    Color(0xFF81C784),
    Color(0xFF4CAF50),
    Color(0xFF2E7D32),
  ];

  static const List<Color> musicGradient = [
    Color(0xFF9575CD),
    Color(0xFF7E57C2),
    Color(0xFF673AB7),
  ];

  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Border Radius - Modern, subtle values
  static const double radiusSmall = 6.0;
  static const double radiusButton = 10.0;
  static const double radiusCard = 12.0;
  static const double radiusChip = 20.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Elevation
  static const double elevationCard = 2.0;
  static const double elevationCardDark = 4.0;
  static const double elevationButton = 1.0;
  static const double elevationFab = 6.0;
  static const double elevationAppBar = 0.0;
  static const double elevationAppBarScrolled = 2.0;
  static const double elevationBottomNav = 8.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationBreathing = Duration(seconds: 4);

  // Opacity
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.87;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  static const double iconXXLarge = 64.0;

  // Video Player Colors
  static const Color videoControlsBackground = Color(0x99000000);
  static const Color videoProgressPlayed = taiChiGreen;
  static const Color videoProgressBuffered = Color(0x33FFFFFF);
  static const Color videoProgressBackground = Color(0x66FFFFFF);

  // Ad Banner Colors
  static const Color adBannerBackground = Color(0xFFF0F0F0);
  static const Color adBannerBorder = Color(0xFFE0E0E0);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF424242);
  static const Color shimmerHighlightDark = Color(0xFF616161);

  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static LinearGradient createGradient(
    List<Color> colors, {
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
    );
  }

  static RadialGradient createRadialGradient(
    List<Color> colors, {
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: colors,
    );
  }
}