import 'package:hive/hive.dart';
import '../../core/error/exceptions.dart';
import '../models/video_model.dart';
import '../models/lesson_model.dart';

abstract class VideoLocalDataSource {
  Future<List<VideoModel>> getCachedVideos();
  Future<List<LessonModel>> getCachedLessons();
  Future<VideoModel?> getCachedVideo(String id);
  Future<LessonModel?> getCachedLesson(String id);
  Future<void> cacheVideos(List<VideoModel> videos);
  Future<void> cacheLessons(List<LessonModel> lessons);
  Future<void> clearVideoCache();
  Future<void> clearLessonCache();
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  static const String videoBoxName = 'videos_cache';
  static const String lessonBoxName = 'lessons_cache';

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    try {
      final box = await Hive.openBox<Map>(videoBoxName);
      final videos = <VideoModel>[];
      
      for (final videoMap in box.values) {
        if (videoMap is Map<String, dynamic>) {
          videos.add(VideoModel.fromJson(videoMap));
        }
      }
      
      return videos;
    } catch (e) {
      throw CacheException('Failed to get cached videos: $e');
    }
  }

  @override
  Future<List<LessonModel>> getCachedLessons() async {
    try {
      final box = await Hive.openBox<Map>(lessonBoxName);
      final lessons = <LessonModel>[];
      
      for (final lessonMap in box.values) {
        if (lessonMap is Map<String, dynamic>) {
          lessons.add(LessonModel.fromJson(lessonMap));
        }
      }
      
      return lessons;
    } catch (e) {
      throw CacheException('Failed to get cached lessons: $e');
    }
  }

  @override
  Future<VideoModel?> getCachedVideo(String id) async {
    try {
      final box = await Hive.openBox<Map>(videoBoxName);
      final videoMap = box.get(id);
      
      if (videoMap != null && videoMap is Map<String, dynamic>) {
        return VideoModel.fromJson(videoMap);
      }
      
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached video: $e');
    }
  }

  @override
  Future<LessonModel?> getCachedLesson(String id) async {
    try {
      final box = await Hive.openBox<Map>(lessonBoxName);
      final lessonMap = box.get(id);
      
      if (lessonMap != null && lessonMap is Map<String, dynamic>) {
        return LessonModel.fromJson(lessonMap);
      }
      
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached lesson: $e');
    }
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    try {
      final box = await Hive.openBox<Map>(videoBoxName);
      
      for (final video in videos) {
        await box.put(video.id, video.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache videos: $e');
    }
  }

  @override
  Future<void> cacheLessons(List<LessonModel> lessons) async {
    try {
      final box = await Hive.openBox<Map>(lessonBoxName);
      
      for (final lesson in lessons) {
        await box.put(lesson.id, lesson.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache lessons: $e');
    }
  }

  @override
  Future<void> clearVideoCache() async {
    try {
      final box = await Hive.openBox<Map>(videoBoxName);
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear video cache: $e');
    }
  }

  @override
  Future<void> clearLessonCache() async {
    try {
      final box = await Hive.openBox<Map>(lessonBoxName);
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear lesson cache: $e');
    }
  }

  Future<bool> isVideoCached(String videoId) async {
    try {
      final box = await Hive.openBox<Map>(videoBoxName);
      return box.containsKey(videoId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLessonCached(String lessonId) async {
    try {
      final box = await Hive.openBox<Map>(lessonBoxName);
      return box.containsKey(lessonId);
    } catch (e) {
      return false;
    }
  }

  Future<DateTime?> getLastCacheUpdate() async {
    try {
      final box = await Hive.openBox<String>('cache_metadata');
      final timestamp = box.get('last_update');
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCacheTimestamp() async {
    try {
      final box = await Hive.openBox<String>('cache_metadata');
      await box.put('last_update', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException('Failed to update cache timestamp: $e');
    }
  }
}