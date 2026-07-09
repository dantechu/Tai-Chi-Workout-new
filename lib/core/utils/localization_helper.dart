import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Helper class for content localization based on user's device language.
///
/// Provides utilities for resolving multilingual fields from Firestore data
/// following the pattern: `fieldName` for English, `fieldName_{langCode}` for translations.
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

  /// Get localized field from a Map with automatic fallback to English.
  ///
  /// This follows the pattern: `fieldName` for English, `fieldName_{langCode}` for translations.
  ///
  /// Example:
  /// ```dart
  /// String title = LocalizationHelper.getLocalizedField(lesson, 'title', 'de');
  /// String content = LocalizationHelper.getLocalizedField(lesson, 'content', 'ja');
  /// ```
  static String getLocalizedField(
    Map<String, dynamic> data,
    String field,
    String languageCode,
  ) {
    // English is the default, no suffix
    if (languageCode == 'en') {
      return data[field]?.toString() ?? '';
    }

    // Try language-specific field
    final localizedKey = '${field}_$languageCode';
    final localizedValue = data[localizedKey];

    if (localizedValue != null && localizedValue.toString().isNotEmpty) {
      return localizedValue.toString();
    }

    // Fall back to English
    return data[field]?.toString() ?? '';
  }

  /// Get localized field or null if not found.
  /// Useful for optional fields like descriptions.
  static String? getLocalizedFieldOrNull(
    Map<String, dynamic> data,
    String field,
    String languageCode,
  ) {
    // English is the default, no suffix
    if (languageCode == 'en') {
      final value = data[field];
      return value?.toString().isNotEmpty == true ? value.toString() : null;
    }

    // Try language-specific field
    final localizedKey = '${field}_$languageCode';
    final localizedValue = data[localizedKey];

    if (localizedValue != null && localizedValue.toString().isNotEmpty) {
      return localizedValue.toString();
    }

    // Fall back to English
    final englishValue = data[field];
    return englishValue?.toString().isNotEmpty == true
        ? englishValue.toString()
        : null;
  }

  /// For nested objects like quiz questions and flashcard items.
  /// Same as getLocalizedField but with a clearer name for nested usage.
  static String getNestedLocalizedField(
    Map<String, dynamic> data,
    String field,
    String languageCode,
  ) {
    return getLocalizedField(data, field, languageCode);
  }

  /// Get the localized suffix for a field based on language code.
  /// Returns empty string for English.
  static String getFieldSuffix(String languageCode) {
    if (languageCode == 'en') return '';
    return '_$languageCode';
  }

  /// Build the localized field key for a given base field and language.
  static String buildLocalizedFieldKey(String field, String languageCode) {
    if (languageCode == 'en') return field;
    return '${field}_$languageCode';
  }

  /// Get localized category name from English category name.
  /// Maps category titles to their localized equivalents.
  static String getLocalizedCategoryName(
      BuildContext context, String categoryName) {
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

  /// Get the original English category name from a localized name.
  /// This is used for filtering when a user selects a localized category.
  static String getEnglishCategoryName(
      BuildContext context, String localizedName) {
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

  /// Get display name for a language code.
  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'zh':
        return '中文';
      default:
        return languageCode.toUpperCase();
    }
  }

  /// Get flag emoji for a language code.
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'de':
        return '🇩🇪';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'zh':
        return '🇨🇳';
      default:
        return '🌐';
    }
  }
}
