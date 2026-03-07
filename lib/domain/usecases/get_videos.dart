import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/video.dart';
import '../repositories/video_repository.dart';

class GetVideos {
  final VideoRepository repository;

  GetVideos(this.repository);

  Future<Either<Failure, List<Video>>> call() async {
    return await repository.getAllVideos();
  }
}

class GetVideosByCategory {
  final VideoRepository repository;

  GetVideosByCategory(this.repository);

  Future<Either<Failure, List<Video>>> call(String category) async {
    return await repository.getVideosByCategory(category);
  }
}

class SearchVideos {
  final VideoRepository repository;

  SearchVideos(this.repository);

  Future<Either<Failure, List<Video>>> call(String query) async {
    return await repository.searchVideos(query);
  }
}

class SearchVideosAcrossAllCourses {
  final VideoRepository repository;

  SearchVideosAcrossAllCourses(this.repository);

  Future<Either<Failure, List<Video>>> call(String query) async {
    return await repository.searchVideosAcrossAllCourses(query);
  }
}

class GetVideo {
  final VideoRepository repository;

  GetVideo(this.repository);

  Future<Either<Failure, Video>> call(String id) async {
    return await repository.getVideo(id);
  }
}