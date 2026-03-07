import 'package:dio/dio.dart';
import '../../core/error/exceptions.dart';
import '../../domain/repositories/course_repository.dart';
import '../models/video_model.dart';
import '../models/lesson_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getAllVideos();
  Future<List<VideoModel>> getAllVideosFromAllCourses();
  Future<List<LessonModel>> getAllLessons();
  Future<VideoModel> getVideo(String id);
  Future<LessonModel> getLesson(String id);
  Future<List<VideoModel>> getVideosByCategory(String category);
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio dio;
  final CourseRepository courseRepository;

  VideoRemoteDataSourceImpl(this.dio, this.courseRepository);

  @override
  Future<List<VideoModel>> getAllVideos() async {
    try {
      // Get the selected course
      final courseResult = await courseRepository.getSelectedCourse();

      return courseResult.fold(
        (failure) {
          // If no course is selected or error, return empty list
          throw ServerException('No course selected: ${failure.message}');
        },
        (course) {
          // Extract all videos from all sections of the selected course
          final allVideos = <VideoModel>[];
          for (final section in course.sections) {
            for (final video in section.videos) {
              // Ensure the video's category field is set to the section title and courseId is set
              final videoWithCategory = video.copyWith(
                category: section.title,
                courseId: course.id,
              );
              allVideos.add(VideoModel.fromEntity(videoWithCategory));
            }
          }
          return allVideos;
        },
      );
    } catch (e) {
      throw ServerException('Failed to load videos: $e');
    }
  }

  @override
  Future<List<VideoModel>> getAllVideosFromAllCourses() async {
    try {
      // Get all active courses
      final coursesResult = await courseRepository.getActiveCourses();

      return coursesResult.fold(
        (failure) {
          throw ServerException('Failed to load courses: ${failure.message}');
        },
        (courses) {
          // Extract all videos from all sections of all courses
          final allVideos = <VideoModel>[];
          for (final course in courses) {
            for (final section in course.sections) {
              for (final video in section.videos) {
                // Ensure the video's category field is set to the section title and courseId is set
                final videoWithMetadata = video.copyWith(
                  category: section.title,
                  courseId: course.id,
                );
                allVideos.add(VideoModel.fromEntity(videoWithMetadata));
              }
            }
          }
          return allVideos;
        },
      );
    } catch (e) {
      throw ServerException('Failed to load videos from all courses: $e');
    }
  }

  @override
  Future<List<LessonModel>> getAllLessons() async {
    try {
      // Get the selected course
      final courseResult = await courseRepository.getSelectedCourse();

      return courseResult.fold(
        (failure) {
          throw ServerException('No course selected: ${failure.message}');
        },
        (course) {
          // Convert course sections to lesson models
          final lessons = <LessonModel>[];
          for (final section in course.sections) {
            // Ensure videos have the section title as their category
            final videosWithCategory = section.videos.map((v) =>
              VideoModel.fromEntity(v.copyWith(category: section.title))
            ).toList();

            final lesson = LessonModel(
              id: section.id,
              title: section.title,
              description: section.description,
              videos: videosWithCategory,
              order: section.order,
              sectionNumber: section.sectionNumber,
            );
            lessons.add(lesson);
          }
          return lessons;
        },
      );
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