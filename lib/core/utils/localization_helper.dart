import 'package:flutter/material.dart';

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
}
