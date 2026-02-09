import 'package:hive/hive.dart';
import '../../core/error/exceptions.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isFirstTime();
  Future<void> setFirstTimeFalse();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const String onboardingBoxName = 'onboarding_prefs';
  static const String isFirstTimeKey = 'is_first_time';

  @override
  Future<bool> isFirstTime() async {
    try {
      final box = await Hive.openBox<bool>(onboardingBoxName);
      // Returns true if key doesn't exist (first time user)
      return box.get(isFirstTimeKey, defaultValue: true) ?? true;
    } catch (e) {
      throw CacheException('Failed to check first time status: $e');
    }
  }

  @override
  Future<void> setFirstTimeFalse() async {
    try {
      final box = await Hive.openBox<bool>(onboardingBoxName);
      await box.put(isFirstTimeKey, false);
    } catch (e) {
      throw CacheException('Failed to set first time status: $e');
    }
  }
}
