import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/video.dart';
import '../entities/lesson.dart';

abstract class VideoRepository {
  Future<Either<Failure, List<Video>>> getAllVideos();
  Future<Either<Failure, List<Video>>> getAllVideosFromAllCourses();
  Future<Either<Failure, List<Lesson>>> getAllLessons();
  Future<Either<Failure, Video>> getVideo(String id);
  Future<Either<Failure, Lesson>> getLesson(String id);
  Future<Either<Failure, List<Video>>> getVideosByCategory(String category);
  Future<Either<Failure, List<Video>>> searchVideos(String query);
  Future<Either<Failure, List<Video>>> searchVideosAcrossAllCourses(String query);
  Future<Either<Failure, List<Video>>> getFreeVideos();
  Future<Either<Failure, List<Video>>> getPremiumVideos();
  Future<Either<Failure, bool>> cacheVideos(List<Video> videos);
  Future<Either<Failure, List<Video>>> getCachedVideos();
}