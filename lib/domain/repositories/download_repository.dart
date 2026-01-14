import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/download_item.dart';
import '../entities/video.dart';

abstract class DownloadRepository {
  Future<Either<Failure, DownloadItem>> downloadVideo(Video video);
  Future<Either<Failure, bool>> pauseDownload(String downloadId);
  Future<Either<Failure, bool>> resumeDownload(String downloadId);
  Future<Either<Failure, bool>> cancelDownload(String downloadId);
  Future<Either<Failure, bool>> deleteDownload(String downloadId);
  Future<Either<Failure, List<DownloadItem>>> getAllDownloads();
  Future<Either<Failure, List<DownloadItem>>> getCompletedDownloads();
  Future<Either<Failure, List<DownloadItem>>> getActiveDownloads();
  Future<Either<Failure, DownloadItem?>> getDownloadByVideoId(String videoId);
  Future<Either<Failure, bool>> isVideoDownloaded(String videoId);
  Future<Either<Failure, String?>> getLocalVideoPath(String videoId);
  Stream<DownloadItem> get downloadProgressStream;
  Stream<List<DownloadItem>> get downloadsStream;
}