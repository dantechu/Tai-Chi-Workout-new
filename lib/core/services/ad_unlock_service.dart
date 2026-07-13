import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/ad_constants.dart';

/// Service to manage lessons unlocked via rewarded ads.
///
/// Features:
/// - Permanently stores unlocked lesson IDs locally
/// - Tracks daily unlock count (resets at midnight)
/// - Enforces daily unlock limit
class AdUnlockService {
  static final AdUnlockService _instance = AdUnlockService._internal();
  factory AdUnlockService() => _instance;
  AdUnlockService._internal();

  static const String _unlockedLessonsKey = 'ad_unlocked_lessons';
  static const String _dailyUnlockCountKey = 'daily_ad_unlock_count';
  static const String _lastUnlockDateKey = 'last_ad_unlock_date';

  SharedPreferences? _prefs;
  Set<String> _unlockedLessonIds = {};
  int _dailyUnlockCount = 0;
  DateTime? _lastUnlockDate;

  /// Initialize the service - must be called before use
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUnlockedLessons();
    _loadDailyCount();
    debugPrint('AdUnlockService: Initialized with ${_unlockedLessonIds.length} unlocked lessons');
  }

  void _loadUnlockedLessons() {
    final List<String>? savedIds = _prefs?.getStringList(_unlockedLessonsKey);
    if (savedIds != null) {
      _unlockedLessonIds = savedIds.toSet();
    }
  }

  void _loadDailyCount() {
    final String? lastDateStr = _prefs?.getString(_lastUnlockDateKey);
    if (lastDateStr != null) {
      _lastUnlockDate = DateTime.tryParse(lastDateStr);
    }

    // Check if we need to reset (new day)
    final today = DateTime.now();
    if (_lastUnlockDate == null ||
        _lastUnlockDate!.year != today.year ||
        _lastUnlockDate!.month != today.month ||
        _lastUnlockDate!.day != today.day) {
      // New day - reset count
      _dailyUnlockCount = 0;
      _lastUnlockDate = today;
      _saveDailyCount();
    } else {
      _dailyUnlockCount = _prefs?.getInt(_dailyUnlockCountKey) ?? 0;
    }
  }

  Future<void> _saveUnlockedLessons() async {
    await _prefs?.setStringList(_unlockedLessonsKey, _unlockedLessonIds.toList());
  }

  Future<void> _saveDailyCount() async {
    await _prefs?.setInt(_dailyUnlockCountKey, _dailyUnlockCount);
    await _prefs?.setString(_lastUnlockDateKey, DateTime.now().toIso8601String());
  }

  /// Check if a lesson is unlocked via ad
  bool isLessonUnlocked(String lessonId) {
    return _unlockedLessonIds.contains(lessonId);
  }

  /// Check if user can unlock more lessons today
  bool canUnlockMore() {
    // Refresh daily count in case day changed
    _loadDailyCount();
    return _dailyUnlockCount < AdConstants.maxDailyAdUnlocks;
  }

  /// Get remaining unlocks for today
  int get remainingUnlocksToday {
    _loadDailyCount();
    return (AdConstants.maxDailyAdUnlocks - _dailyUnlockCount).clamp(0, AdConstants.maxDailyAdUnlocks);
  }

  /// Get daily unlock limit
  int get dailyLimit => AdConstants.maxDailyAdUnlocks;

  /// Unlock a lesson after watching an ad
  Future<bool> unlockLesson(String lessonId) async {
    if (!canUnlockMore()) {
      debugPrint('AdUnlockService: Daily limit reached, cannot unlock');
      return false;
    }

    _unlockedLessonIds.add(lessonId);
    _dailyUnlockCount++;
    _lastUnlockDate = DateTime.now();

    await _saveUnlockedLessons();
    await _saveDailyCount();

    debugPrint('AdUnlockService: Unlocked lesson $lessonId (${remainingUnlocksToday} unlocks remaining today)');
    return true;
  }

  /// Check if user can access a premium lesson (either premium user or ad-unlocked)
  bool canAccessLesson(String lessonId, bool isPremiumUser) {
    if (isPremiumUser) return true;
    return isLessonUnlocked(lessonId);
  }
}
