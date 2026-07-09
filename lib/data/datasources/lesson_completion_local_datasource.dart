import 'package:hive/hive.dart';
import '../../core/error/exceptions.dart';
import '../models/lesson_completion_model.dart';

abstract class LessonCompletionLocalDataSource {
  Future<List<LessonCompletionModel>> getAllCompletions();
  Future<void> markCompleted(String lessonId, {int? scorePercentage});
  Future<void> removeCompletion(String lessonId);
  Future<bool> isLessonCompleted(String lessonId);
  Future<LessonCompletionModel?> getCompletion(String lessonId);
  Future<void> clearAllCompletions();
  Future<int> getCompletedCount();
}

class LessonCompletionLocalDataSourceImpl implements LessonCompletionLocalDataSource {
  static const String completionBoxName = 'lesson_completions_cache';

  @override
  Future<List<LessonCompletionModel>> getAllCompletions() async {
    try {
      final box = await Hive.openBox<Map>(completionBoxName);
      final completions = <LessonCompletionModel>[];

      for (final completionMap in box.values) {
        final typedMap = Map<String, dynamic>.from(completionMap);
        completions.add(LessonCompletionModel.fromJson(typedMap));
      }

      // Sort by completedAt descending (most recent first)
      completions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      return completions;
    } catch (e) {
      throw CacheException('Failed to get completions: $e');
    }
  }

  @override
  Future<void> markCompleted(String lessonId, {int? scorePercentage}) async {
    try {
      final box = await Hive.openBox<Map>(completionBoxName);

      // Update existing or create new completion
      final completion = LessonCompletionModel.create(
        lessonId,
        scorePercentage: scorePercentage,
      );
      await box.put(lessonId, completion.toJson());
    } catch (e) {
      throw CacheException('Failed to mark lesson completed: $e');
    }
  }

  @override
  Future<void> removeCompletion(String lessonId) async {
    try {
      final box = await Hive.openBox<Map>(completionBoxName);
      await box.delete(lessonId);
    } catch (e) {
      throw CacheException('Failed to remove completion: $e');
    }
  }

  @override
  Future<bool> isLessonCompleted(String lessonId) async {
    try {
      final box = await Hive.openBox<Map>(completionBoxName);
      return box.containsKey(lessonId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<LessonCompletionModel?> getCompletion(String lessonId) async {
    try {
      final box = await Hive.openBox<Map>(completionBoxName);
      final data = box.get(lessonId);
      if (data == null) return null;
      return LessonCompletionModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAllCompletions() async {
    try {
      final box = await Hive.openBox<Map>(completionBoxName);
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear completions: $e');
    }
  }

  @override
  Future<int> getCompletedCount() async {
    try {
      final box = await Hive.openBox<Map>(completionBoxName);
      return box.length;
    } catch (e) {
      return 0;
    }
  }
}
