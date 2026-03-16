import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for logging Firebase Analytics events
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  /// Get the FirebaseAnalytics instance
  FirebaseAnalytics get analytics => _analytics;

  /// Get the FirebaseAnalyticsObserver for navigation tracking
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  // Language Selection Events
  Future<void> logLanguageSelected(String languageCode) async {
    final eventName = _getLanguageEventName(languageCode);
    await _analytics.logEvent(
      name: eventName,
      parameters: {
        'language_code': languageCode,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  String _getLanguageEventName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'english_language_selected';
      case 'zh':
        return 'chinese_language_selected';
      case 'es':
        return 'spanish_language_selected';
      case 'ja':
        return 'japanese_language_selected';
      case 'fr':
        return 'french_language_selected';
      case 'de':
        return 'german_language_selected';
      case 'ko':
        return 'korean_language_selected';
      default:
        return 'unknown_language_selected';
    }
  }

  // Premium Events
  Future<void> logPremiumPurchaseAttempt() async {
    await _analytics.logEvent(
      name: 'premium_purchase_attempt',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logPremiumPurchaseSuccess() async {
    await _analytics.logEvent(
      name: 'premium_purchase_success',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logPremiumPurchaseFailed(String error) async {
    await _analytics.logEvent(
      name: 'premium_purchase_failed',
      parameters: {
        'error': error,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logPremiumRestoreAttempt() async {
    await _analytics.logEvent(
      name: 'premium_restore_attempt',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Video Events
  Future<void> logVideoPlayed(String videoId, String videoTitle) async {
    await _analytics.logEvent(
      name: 'video_played',
      parameters: {
        'video_id': videoId,
        'video_title': videoTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logVideoDownloaded(String videoId, String videoTitle) async {
    await _analytics.logEvent(
      name: 'video_downloaded',
      parameters: {
        'video_id': videoId,
        'video_title': videoTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logVideoDeleted(String videoId, String videoTitle) async {
    await _analytics.logEvent(
      name: 'video_deleted',
      parameters: {
        'video_id': videoId,
        'video_title': videoTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Course Events
  Future<void> logCourseSelected(String courseId, String courseName) async {
    await _analytics.logEvent(
      name: 'course_selected',
      parameters: {
        'course_id': courseId,
        'course_name': courseName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Practice Events
  Future<void> logBreathingSessionStarted(int durationMinutes) async {
    await _analytics.logEvent(
      name: 'breathing_session_started',
      parameters: {
        'duration_minutes': durationMinutes,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logBreathingSessionCompleted(int durationMinutes) async {
    await _analytics.logEvent(
      name: 'breathing_session_completed',
      parameters: {
        'duration_minutes': durationMinutes,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Theme Events
  Future<void> logThemeChanged(String themeMode) async {
    await _analytics.logEvent(
      name: 'theme_changed',
      parameters: {
        'theme_mode': themeMode,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Music Events
  Future<void> logMusicPlayed(String trackId, String trackTitle) async {
    await _analytics.logEvent(
      name: 'music_played',
      parameters: {
        'track_id': trackId,
        'track_title': trackTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Screen View Events
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }

  // User Properties
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(
      name: name,
      value: value,
    );
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Generic Event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
