class AppConstants {
  static const String appName = 'Tai Chi Workout';
  static const String appVersion = '1.0.0';
  static const String bundleId = 'com.amazingelearning.taichi';
  
  // Contact Information
  static const String supportEmail = 'support@amazingelearning.com';
  static const String supportPhone = '1(650)692-2500';
  static const String website = 'www.amazingelearning.com';
  
  // URLs
  static const String privacyPolicyUrl = 'https://www.amazingelearning.com/privacy';
  static const String termsOfServiceUrl = 'https://www.amazingelearning.com/terms';
  
  // Premium
  static const String premiumProductId = 'com.amazingelearning.taichi.premium';
  static const String premiumPrice = '\$9.99';
  
  // Storage Keys
  static const String hiveVideoBox = 'videos_box';
  static const String hiveDownloadBox = 'downloads_box';
  static const String hivePremiumBox = 'premium_box';
  static const String hiveSettingsBox = 'settings_box';
  static const String hiveFavoritesBox = 'favorites_box';
  
  // Secure Storage Keys
  static const String premiumTokenKey = 'premium_token';
  static const String userIdKey = 'user_id';
  
  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String onboardingKey = 'onboarding_complete';
  
  // Video Categories
  static const List<Map<String, dynamic>> videoCategories = [
    {
      'section': 1,
      'title': 'About Us',
      'videos': [
        {'row': 1, 'title': 'About us', 'isPremium': false}
      ]
    },
    {
      'section': 2,
      'title': 'Intro by John Saxxon',
      'videos': [
        {'row': 1, 'title': 'Intro by John Saxxon', 'isPremium': false},
        {'row': 2, 'title': 'Course Outline', 'isPremium': false}
      ]
    },
    {
      'section': 3,
      'title': 'Structure',
      'videos': [
        {'row': 1, 'title': 'Structure Part 1', 'isPremium': true},
        {'row': 2, 'title': 'Structure Part 2', 'isPremium': true},
        {'row': 3, 'title': 'Structure Part 3', 'isPremium': true}
      ]
    },
    {
      'section': 4,
      'title': 'Flexibility',
      'videos': [
        {'row': 1, 'title': 'Flexibility Part 1', 'isPremium': true},
        {'row': 2, 'title': 'Flexibility Part 2', 'isPremium': true},
        {'row': 3, 'title': 'Flexibility Part 3', 'isPremium': true}
      ]
    },
    {
      'section': 5,
      'title': 'Fluidity',
      'videos': [
        {'row': 1, 'title': 'Fluidity Movement 1', 'isPremium': true},
        {'row': 2, 'title': 'Fluidity Movement 2', 'isPremium': true},
        {'row': 3, 'title': 'Fluidity Movement 3', 'isPremium': true},
        {'row': 4, 'title': 'Fluidity Movement 4', 'isPremium': true},
        {'row': 5, 'title': 'Fluidity Movement 5', 'isPremium': true},
        {'row': 6, 'title': 'Fluidity Movement 6', 'isPremium': true},
        {'row': 7, 'title': 'Fluidity Movement 7', 'isPremium': true},
        {'row': 8, 'title': 'Fluidity Movement 8', 'isPremium': true},
        {'row': 9, 'title': 'Fluidity Movement 9', 'isPremium': true},
        {'row': 10, 'title': 'Fluidity Movement 10', 'isPremium': true}
      ]
    },
    {
      'section': 6,
      'title': 'Power',
      'videos': [
        {'row': 1, 'title': 'Power Part 1', 'isPremium': true},
        {'row': 2, 'title': 'Power Part 2', 'isPremium': true},
        {'row': 3, 'title': 'Power Part 3', 'isPremium': true}
      ]
    }
  ];
  
  // Audio Tracks
  static const List<Map<String, dynamic>> musicTracks = [
    {
      'id': 'tai_chi_calm',
      'title': 'Tai Chi Calm',
      'file': 'assets/audio/music/tai_chi_calm.mp3',
      'duration': Duration(minutes: 10),
    },
    {
      'id': 'meditation_flow',
      'title': 'Meditation Flow',
      'file': 'assets/audio/music/meditation_flow.mp3',
      'duration': Duration(minutes: 15),
    },
    {
      'id': 'peaceful_chi',
      'title': 'Peaceful Chi',
      'file': 'assets/audio/music/peaceful_chi.mp3',
      'duration': Duration(minutes: 12),
    },
  ];
  
  // Supported Locales
  static const List<Map<String, dynamic>> supportedLocales = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'zh', 'name': '简体中文', 'flag': '🇨🇳'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
  ];
}