import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/video_remote_datasource.dart';
import '../datasources/video_local_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final CourseRepository courseRepository;

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.courseRepository,
  });

  /// Helper method to get the selected course ID for offline filtering
  Future<String?> _getSelectedCourseId() async {
    final courseResult = await courseRepository.getSelectedCourse();
    return courseResult.fold(
      (failure) => null,
      (course) => course.id,
    );
  }

  @override
  Future<Either<Failure, List<Video>>> getAllVideos() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteVideos = await remoteDataSource.getAllVideos();
        await localDataSource.cacheVideos(remoteVideos);
        return Right(remoteVideos.cast<Video>());
      } else {
        // When offline, filter cached videos by the selected course
        final selectedCourseId = await _getSelectedCourseId();
        final localVideos = await localDataSource.getCachedVideosByCourse(selectedCourseId);
        if (localVideos.isNotEmpty) {
          return Right(localVideos.cast<Video>());
        } else {
          return Left(NetworkFailure('No internet connection and no cached data for this course'));
        }
      }
    } on ServerException catch (e) {
      try {
        // On server error, also filter by selected course
        final selectedCourseId = await _getSelectedCourseId();
        final localVideos = await localDataSource.getCachedVideosByCourse(selectedCourseId);
        if (localVideos.isNotEmpty) {
          return Right(localVideos.cast<Video>());
        } else {
          return Left(ServerFailure(e.message));
        }
      } on CacheException catch (cacheError) {
        return Left(ServerFailure('${e.message} and ${cacheError.message}'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Lesson>>> getAllLessons() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteLessons = await remoteDataSource.getAllLessons();
        await localDataSource.cacheLessons(remoteLessons);
        return Right(remoteLessons.cast<Lesson>());
      } else {
        // When offline, filter cached lessons by the selected course
        final selectedCourseId = await _getSelectedCourseId();
        final localLessons = await localDataSource.getCachedLessonsByCourse(selectedCourseId);
        if (localLessons.isNotEmpty) {
          return Right(localLessons.cast<Lesson>());
        } else {
          return Left(NetworkFailure('No internet connection and no cached data for this course'));
        }
      }
    } on ServerException catch (e) {
      try {
        // On server error, also filter by selected course
        final selectedCourseId = await _getSelectedCourseId();
        final localLessons = await localDataSource.getCachedLessonsByCourse(selectedCourseId);
        if (localLessons.isNotEmpty) {
          return Right(localLessons.cast<Lesson>());
        } else {
          return Left(ServerFailure(e.message));
        }
      } on CacheException catch (cacheError) {
        return Left(ServerFailure('${e.message} and ${cacheError.message}'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Video>> getVideo(String id) async {
    try {
      // Try local first for faster response
      final localVideo = await localDataSource.getCachedVideo(id);
      if (localVideo != null) {
        return Right(localVideo);
      }

      if (await networkInfo.isConnected) {
        final remoteVideo = await remoteDataSource.getVideo(id);
        await localDataSource.cacheVideos([remoteVideo]);
        return Right(remoteVideo);
      } else {
        return Left(NetworkFailure('Video not found locally and no internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Lesson>> getLesson(String id) async {
    try {
      // Try local first for faster response
      final localLesson = await localDataSource.getCachedLesson(id);
      if (localLesson != null) {
        return Right(localLesson);
      }

      if (await networkInfo.isConnected) {
        final remoteLesson = await remoteDataSource.getLesson(id);
        await localDataSource.cacheLessons([remoteLesson]);
        return Right(remoteLesson);
      } else {
        return Left(NetworkFailure('Lesson not found locally and no internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCategory(String category) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteVideos = await remoteDataSource.getVideosByCategory(category);
        return Right(remoteVideos.cast<Video>());
      } else {
        // When offline, filter by both course and category
        final selectedCourseId = await _getSelectedCourseId();
        final localVideos = await localDataSource.getCachedVideosByCourse(selectedCourseId);
        final filteredVideos = localVideos.where(
          (video) => video.category.toLowerCase() == category.toLowerCase()
        ).toList();

        if (filteredVideos.isNotEmpty) {
          return Right(filteredVideos.cast<Video>());
        } else {
          return Left(NetworkFailure('No videos found for category $category and no internet connection'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getAllVideosFromAllCourses() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteVideos = await remoteDataSource.getAllVideosFromAllCourses();
        return Right(remoteVideos.cast<Video>());
      } else {
        // When offline, still use cached videos but don't filter by course
        final localVideos = await localDataSource.getCachedVideos();
        if (localVideos.isNotEmpty) {
          return Right(localVideos.cast<Video>());
        } else {
          return Left(NetworkFailure('No internet connection and no cached data'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> searchVideos(String query) async {
    try {
      final videosResult = await getAllVideos();
      return videosResult.fold(
        (failure) => Left(failure),
        (videos) {
          final searchResults = videos.where((video) =>
            video.title.toLowerCase().contains(query.toLowerCase()) ||
            video.category.toLowerCase().contains(query.toLowerCase()) ||
            (video.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            video.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
          ).toList();
          return Right(searchResults);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Search failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> searchVideosAcrossAllCourses(String query) async {
    try {
      final videosResult = await getAllVideosFromAllCourses();
      return videosResult.fold(
        (failure) => Left(failure),
        (videos) {
          final searchResults = videos.where((video) =>
            video.title.toLowerCase().contains(query.toLowerCase()) ||
            video.category.toLowerCase().contains(query.toLowerCase()) ||
            (video.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            video.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
          ).toList();
          return Right(searchResults);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Search across all courses failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getFreeVideos() async {
    try {
      final videosResult = await getAllVideos();
      return videosResult.fold(
        (failure) => Left(failure),
        (videos) {
          final freeVideos = videos.where((video) => !video.isPremium).toList();
          return Right(freeVideos);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get free videos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getPremiumVideos() async {
    try {
      final videosResult = await getAllVideos();
      return videosResult.fold(
        (failure) => Left(failure),
        (videos) {
          final premiumVideos = videos.where((video) => video.isPremium).toList();
          return Right(premiumVideos);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get premium videos: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> cacheVideos(List<Video> videos) async {
    try {
      final videoModels = videos.map((video) {
        if (video is Video) {
          return video;
        } else {
          throw Exception('Invalid video type');
        }
      }).toList();
      
      await localDataSource.cacheVideos(videoModels.cast());
      return Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to cache videos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getCachedVideos() async {
    try {
      final localVideos = await localDataSource.getCachedVideos();
      return Right(localVideos.cast<Video>());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get cached videos: $e'));
    }
  }
}