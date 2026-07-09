import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY COLORS - Excel Green (Professional, Productive, Modern)
  // Microsoft Excel brand colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color excelGreen = Color(0xFF107C41);            // Primary Excel green
  static const Color excelGreenLight = Color(0xFF1D9E53);       // Lighter Excel green
  static const Color excelGreenDark = Color(0xFF0B5A2F);        // Deep Excel green
  static const Color excelGreenSoft = Color(0xFF33C481);        // Soft accent green

  // Legacy aliases for compatibility (maps to new colors)
  static const Color warmBrown = excelGreen;
  static const Color warmBrownLight = excelGreenLight;
  static const Color warmBrownDark = excelGreenDark;
  static const Color warmBrownSoft = excelGreenSoft;
  static const Color deepNavy = excelGreen;
  static const Color deepNavyLight = excelGreenLight;
  static const Color deepNavyDark = excelGreenDark;
  static const Color deepNavySoft = excelGreenSoft;

  // Tai Chi / Qigong brand color aliases
  static const Color taiChiGreen = Color(0xFF2E7D32);              // Natural forest green
  static const Color taiChiGreenLight = Color(0xFF4CAF50);         // Light natural green
  static const Color taiChiGreenDark = Color(0xFF1B5E20);          // Deep forest green
  static const Color earthyBrown = Color(0xFF795548);              // Earthy brown
  static const Color earthyBrownLight = Color(0xFF8D6E63);         // Light earthy brown
  static const Color calmBlue = Color(0xFF0288D1);                 // Calm sky blue
  static const Color calmBlueLight = Color(0xFF03A9F4);            // Light sky blue

  // ═══════════════════════════════════════════════════════════════════════════
  // SECONDARY COLORS - Excel Accent Green (Highlights, Actions)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color excelAccent = Color(0xFF21A366);           // Accent green
  static const Color excelAccentLight = Color(0xFF33C481);      // Light accent
  static const Color excelAccentDark = Color(0xFF185C37);       // Dark accent

  // Legacy aliases for compatibility
  static const Color goldenTan = excelAccent;
  static const Color goldenTanLight = excelAccentLight;
  static const Color goldenTanDark = excelAccentDark;
  static const Color softTeal = excelAccent;
  static const Color softTealLight = excelAccentLight;
  static const Color softTealDark = excelAccentDark;

  // ═══════════════════════════════════════════════════════════════════════════
  // TERTIARY COLORS - Office Gray (Professional, Clean)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color officeGray = Color(0xFFE6E6E6);            // Light gray
  static const Color officeGrayLight = Color(0xFFF3F3F3);       // Very light gray
  static const Color officeGrayDark = Color(0xFFD0D0D0);        // Medium gray

  // Legacy aliases for compatibility
  static const Color softCream = officeGray;
  static const Color softCreamLight = officeGrayLight;
  static const Color softCreamDark = officeGrayDark;
  static const Color warmGold = excelAccent;
  static const Color warmGoldLight = excelAccentLight;
  static const Color warmGoldDark = excelAccentDark;

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS - Subtle Off-White (Udemy-style)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color backgroundLight = Color(0xFFF7F9FA);       // Subtle off-white (Udemy-like)
  static const Color backgroundLightAlt = Color(0xFFEFEFEF);    // Slightly darker for contrast
  static const Color cardBackground = Color(0xFFFFFFFF);        // Pure white for cards
  static const Color backgroundDark = Color(0xFF1A1A1A);        // Rich dark
  static const Color surfaceDark = Color(0xFF242424);           // Elevated dark surface
  static const Color surfaceDarkAlt = Color(0xFF2E2E2E);        // Cards in dark mode

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS - High Contrast, Readable
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF1C1D1F);           // Near black (Udemy-like)
  static const Color textSecondary = Color(0xFF6A6F73);         // Medium gray
  static const Color textTertiary = Color(0xFF9EA5AB);          // Light gray
  static const Color textPrimaryDark = Color(0xFFF7F9FA);       // Near white
  static const Color textSecondaryDark = Color(0xFFB8BBBE);     // Light gray
  static const Color textTertiaryDark = Color(0xFF6A6F73);      // Medium gray

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS - Clear, Standard
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color errorLight = Color(0xFFD32F2F);            // Material red
  static const Color errorDark = Color(0xFFEF5350);             // Lighter red for dark
  static const Color success = Color(0xFF107C41);               // Excel green (success)
  static const Color successDark = Color(0xFF33C481);           // Lighter green for dark
  static const Color warning = Color(0xFFF57C00);               // Orange warning
  static const Color warningDark = Color(0xFFFFB74D);           // Lighter orange for dark
  static const Color info = Color(0xFF1976D2);                  // Blue info
  static const Color infoDark = Color(0xFF64B5F6);              // Lighter blue for dark

  // ═══════════════════════════════════════════════════════════════════════════
  // PREMIUM COLORS - Professional Gold/Green
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color premiumGold = Color(0xFF107C41);           // Excel green for premium
  static const Color premiumGoldLight = Color(0xFF33C481);      // Light green
  static const Color premiumGoldDark = Color(0xFF21A366);       // Accent green for dark mode

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCENT COLORS - Office Suite Colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color accentExcel = Color(0xFF107C41);           // Excel green
  static const Color accentWord = Color(0xFF2B579A);            // Word blue
  static const Color accentPowerPoint = Color(0xFFD24726);      // PowerPoint orange
  static const Color accentOutlook = Color(0xFF0078D4);         // Outlook blue

  // Legacy aliases
  static const Color accentTerracotta = accentPowerPoint;
  static const Color accentSage = excelGreen;
  static const Color accentGold = excelAccent;
  static const Color accentMocha = Color(0xFF6B6B6B);
  static const Color accentSky = accentOutlook;
  static const Color accentTeal = excelGreen;
  static const Color accentLavender = Color(0xFF7B68EE);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENT COLORS - Subtle, Professional
  // ═══════════════════════════════════════════════════════════════════════════
  static const List<Color> primaryGradient = [
    Color(0xFF1D9E53),                                          // Excel green light
    Color(0xFF107C41),                                          // Excel green
    Color(0xFF0B5A2F),                                          // Excel green dark
  ];

  static const List<Color> excelGradient = [
    Color(0xFF33C481),                                          // Light green
    Color(0xFF21A366),                                          // Accent green
    Color(0xFF107C41),                                          // Primary green
  ];

  static const List<Color> professionalGradient = [
    Color(0xFF1D9E53),                                          // Light green
    Color(0xFF107C41),                                          // Primary green
  ];

  static const List<Color> subtleGradient = [
    Color(0xFFFFFFFF),                                          // White
    Color(0xFFF7F9FA),                                          // Off-white
  ];

  // Legacy gradient aliases
  static const List<Color> breathingGradient = excelGradient;
  static const List<Color> meditationGradient = primaryGradient;
  static const List<Color> healingGradient = professionalGradient;
  static const List<Color> sunriseGradient = subtleGradient;
  static const List<Color> oceanGradient = excelGradient;

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING - Clean Grid System (8px base)
  // ═══════════════════════════════════════════════════════════════════════════
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS - Consistent System
  // Use radiusMD (8) for most cards, radiusLG (12) for modals/sheets
  // ═══════════════════════════════════════════════════════════════════════════
  static const double radiusXS = 4.0;     // Small elements (badges, tags)
  static const double radiusSM = 6.0;     // Buttons, inputs
  static const double radiusMD = 8.0;     // Cards, tiles
  static const double radiusLG = 12.0;    // Modals, bottom sheets
  static const double radiusXL = 16.0;    // Large containers
  static const double radiusFull = 999.0; // Pills, avatars

  // Legacy aliases - all map to consistent values
  static const double radiusSmall = radiusXS;
  static const double radiusButton = radiusSM;
  static const double radiusCard = radiusMD;
  static const double radiusChip = radiusFull;
  static const double radiusLarge = radiusLG;
  static const double radiusXLarge = radiusXL;
  static const double radiusCircular = radiusFull;

  // ═══════════════════════════════════════════════════════════════════════════
  // ELEVATION - Minimal, Flat Design
  // ═══════════════════════════════════════════════════════════════════════════
  static const double elevationCard = 0.0;
  static const double elevationCardDark = 0.0;
  static const double elevationButton = 0.0;
  static const double elevationFab = 2.0;
  static const double elevationAppBar = 0.0;
  static const double elevationAppBarScrolled = 1.0;
  static const double elevationBottomNav = 0.0;
  static const double elevationDialog = 8.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS - Snappy, Professional
  // ═══════════════════════════════════════════════════════════════════════════
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
  static const Duration animationGentle = Duration(milliseconds: 500);
  static const Duration animationBreathing = Duration(seconds: 4);

  // ═══════════════════════════════════════════════════════════════════════════
  // OPACITY - Standard Levels
  // ═══════════════════════════════════════════════════════════════════════════
  static const double opacityDisabled = 0.38;
  static const double opacityLight = 0.08;
  static const double opacityMedium = 0.54;
  static const double opacityHigh = 0.87;

  // ═══════════════════════════════════════════════════════════════════════════
  // ICON SIZES
  // ═══════════════════════════════════════════════════════════════════════════
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  static const double iconXXLarge = 64.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // VIDEO PLAYER COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color videoControlsBackground = Color(0xE6000000);
  static const Color videoProgressPlayed = excelGreen;
  static const Color videoProgressBuffered = Color(0x4DFFFFFF);
  static const Color videoProgressBackground = Color(0x33FFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // AD BANNER COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color adBannerBackground = Color(0xFFF7F9FA);
  static const Color adBannerBorder = Color(0xFFE0E0E0);

  // ═══════════════════════════════════════════════════════════════════════════
  // SHIMMER COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color shimmerBase = Color(0xFFE8E8E8);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2D2D2D);
  static const Color shimmerHighlightDark = Color(0xFF3D3D3D);

  // ═══════════════════════════════════════════════════════════════════════════
  // DIVIDER/BORDER COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color dividerLight = Color(0xFFE4E8EB);          // Subtle border
  static const Color borderLight = Color(0xFFD1D7DC);           // Visible border (Udemy-like)
  static const Color dividerDark = Color(0xFF3A3A3A);
  static const Color borderDark = Color(0xFF4A4A4A);

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
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

  static LinearGradient createSoftGradient(
    Color color, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        color.withValues(alpha: 0.08),
        color.withValues(alpha: 0.04),
      ],
    );
  }
}
