import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_local_datasource.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadLocalDataSource localDataSource;

  DownloadRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, DownloadItem>> downloadVideo(Video video) async {
    try {
      // Only video and audio lessons can be downloaded
      final url = video.videoUrl ?? video.audioUrl;
      if (url == null || url.isEmpty) {
        return const Left(CacheFailure('This lesson type cannot be downloaded'));
      }

      // Determine media type based on what URL is being used
      final mediaType = video.videoUrl != null && video.videoUrl!.isNotEmpty ? 'video' : 'audio';

      final result = await localDataSource.startDownload(
        video.id,
        url,
        title: video.title,
        mediaType: mediaType,
      );
      return Right(result.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to download video: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> pauseDownload(String downloadId) async {
    try {
      final result = await localDataSource.pauseDownload(downloadId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to pause download: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> resumeDownload(String downloadId) async {
    try {
      final result = await localDataSource.resumeDownload(downloadId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to resume download: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelDownload(String downloadId) async {
    try {
      final result = await localDataSource.cancelDownload(downloadId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to cancel download: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDownload(String downloadId) async {
    try {
      final result = await localDataSource.deleteDownload(downloadId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to delete download: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DownloadItem>>> getAllDownloads() async {
    try {
      final result = await localDataSource.getAllDownloads();
      return Right(result.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get all downloads: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DownloadItem>>> getCompletedDownloads() async {
    try {
      final result = await localDataSource.getCompletedDownloads();
      return Right(result.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get completed downloads: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DownloadItem>>> getActiveDownloads() async {
    try {
      final result = await localDataSource.getActiveDownloads();
      return Right(result.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get active downloads: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DownloadItem?>> getDownloadByVideoId(String videoId) async {
    try {
      final result = await localDataSource.getDownloadByVideoId(videoId);
      return Right(result?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get download: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isVideoDownloaded(String videoId) async {
    try {
      final result = await localDataSource.isVideoDownloaded(videoId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to check download status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String?>> getLocalVideoPath(String videoId) async {
    try {
      final result = await localDataSource.getLocalVideoPath(videoId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get local video path: ${e.toString()}'));
    }
  }

  @override
  Stream<DownloadItem> get downloadProgressStream {
    return localDataSource.downloadProgressStream.map((model) => model.toEntity());
  }

  @override
  Stream<List<DownloadItem>> get downloadsStream {
    // This would require implementing in datasource
    return Stream.empty();
  }
}
