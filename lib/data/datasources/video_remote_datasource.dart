import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/video_model.dart';
import '../models/lesson_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getAllVideos();
  Future<List<LessonModel>> getAllLessons();
  Future<VideoModel> getVideo(String id);
  Future<LessonModel> getLesson(String id);
  Future<List<VideoModel>> getVideosByCategory(String category);
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio dio;

  VideoRemoteDataSourceImpl(this.dio);

  @override
  Future<List<VideoModel>> getAllVideos() async {
    try {
      final lessons = await getAllLessons();
      final allVideos = <VideoModel>[];
      
      for (final lesson in lessons) {
        for (final video in lesson.videos) {
          allVideos.add(VideoModel.fromEntity(video));
        }
      }
      
      return allVideos;
    } catch (e) {
      throw ServerException('Failed to load videos: $e');
    }
  }

  @override
  Future<List<LessonModel>> getAllLessons() async {
    try {
      // Using hardcoded data structure from app constants
      final lessons = <LessonModel>[];
      
      for (final categoryData in AppConstants.videoCategories) {
        final lesson = LessonModel.fromCategoryData(categoryData);
        lessons.add(lesson);
      }
      
      return lessons;
    } catch (e) {
      throw ServerException('Failed to load lessons: $e');
    }
  }

  @override
  Future<VideoModel> getVideo(String id) async {
    try {
      final videos = await getAllVideos();
      final video = videos.firstWhere(
        (v) => v.id == id,
        orElse: () => throw ServerException('Video not found with id: $id'),
      );
      return video;
    } catch (e) {
      throw ServerException('Failed to load video: $e');
    }
  }

  @override
  Future<LessonModel> getLesson(String id) async {
    try {
      final lessons = await getAllLessons();
      final lesson = lessons.firstWhere(
        (l) => l.id == id,
        orElse: () => throw ServerException('Lesson not found with id: $id'),
      );
      return lesson;
    } catch (e) {
      throw ServerException('Failed to load lesson: $e');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCategory(String category) async {
    try {
      final videos = await getAllVideos();
      return videos.where((video) => 
        video.category.toLowerCase() == category.toLowerCase()
      ).toList();
    } catch (e) {
      throw ServerException('Failed to load videos by category: $e');
    }
  }

  Future<bool> checkVideoAvailability(String videoUrl) async {
    try {
      final response = await dio.head(videoUrl);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getVideoMetadata(String videoUrl) async {
    try {
      final response = await dio.head(videoUrl);
      
      return {
        'contentLength': response.headers.value('content-length'),
        'contentType': response.headers.value('content-type'),
        'lastModified': response.headers.value('last-modified'),
        'etag': response.headers.value('etag'),
      };
    } catch (e) {
      throw ServerException('Failed to get video metadata: $e');
    }
  }
}