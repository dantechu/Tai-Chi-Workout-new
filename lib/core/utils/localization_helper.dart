import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Helper class for content localization based on user's device language
class LocalizationHelper {
  /// Supported language codes for content localization
  static const List<String> supportedLanguages = [
    'en', // English (default)
    'de', // German
    'es', // Spanish
    'fr', // French
    'ja', // Japanese
    'ko', // Korean
    'zh', // Chinese
  ];

  /// Get the current language code from the device locale
  /// Falls back to 'en' if the locale is not supported
  static String getCurrentLanguageCode(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    // Return the language code if supported, otherwise default to English
    if (supportedLanguages.contains(languageCode)) {
      return languageCode;
    }
    return 'en';
  }

  /// Get the language code from a Locale object
  /// Falls back to 'en' if the locale is not supported
  static String getLanguageCodeFromLocale(Locale? locale) {
    if (locale == null) return 'en';

    final languageCode = locale.languageCode;
    if (supportedLanguages.contains(languageCode)) {
      return languageCode;
    }
    return 'en';
  }

  /// Check if a language code is supported for content localization
  static bool isLanguageSupported(String languageCode) {
    return supportedLanguages.contains(languageCode);
  }

  /// Get localized category name from English category name
  /// Maps category titles to their localized equivalents
  static String getLocalizedCategoryName(BuildContext context, String categoryName) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return categoryName;

    // Normalize the category name for matching
    final normalized = categoryName.toLowerCase().trim();

    // Map category names to localization keys
    if (normalized.contains('about')) {
      return l10n.aboutUs;
    } else if (normalized.contains('intro')) {
      return l10n.intro;
    } else if (normalized.contains('structure')) {
      return l10n.structure;
    } else if (normalized.contains('flexibility')) {
      return l10n.flexibility;
    } else if (normalized.contains('fluidity')) {
      return l10n.fluidity;
    } else if (normalized.contains('power')) {
      return l10n.power;
    }

    // Return original name if no match found
    return categoryName;
  }

  /// Get the original English category name from a localized name
  /// This is used for filtering when a user selects a localized category
  static String getEnglishCategoryName(BuildContext context, String localizedName) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return localizedName;

    // Check against all localized versions
    if (localizedName == l10n.aboutUs) return 'About Us';
    if (localizedName == l10n.intro) return 'Intro by John Saxxon';
    if (localizedName == l10n.structure) return 'Structure';
    if (localizedName == l10n.flexibility) return 'Flexibility';
    if (localizedName == l10n.fluidity) return 'Fluidity';
    if (localizedName == l10n.power) return 'Power';

    // Return the original name if no match (it's probably already in English)
    return localizedName;
  }
}
