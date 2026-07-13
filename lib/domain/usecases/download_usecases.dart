import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/download_item.dart';
import '../entities/video.dart';
import '../repositories/download_repository.dart';

class DownloadVideo {
  final DownloadRepository repository;

  DownloadVideo(this.repository);

  Future<Either<Failure, DownloadItem>> call(Video video) async {
    return await repository.downloadVideo(video);
  }
}

class PauseDownload {
  final DownloadRepository repository;

  PauseDownload(this.repository);

  Future<Either<Failure, bool>> call(String downloadId) async {
    return await repository.pauseDownload(downloadId);
  }
}

class ResumeDownload {
  final DownloadRepository repository;

  ResumeDownload(this.repository);

  Future<Either<Failure, bool>> call(String downloadId) async {
    return await repository.resumeDownload(downloadId);
  }
}

class CancelDownload {
  final DownloadRepository repository;

  CancelDownload(this.repository);

  Future<Either<Failure, bool>> call(String downloadId) async {
    return await repository.cancelDownload(downloadId);
  }
}

class DeleteDownload {
  final DownloadRepository repository;

  DeleteDownload(this.repository);

  Future<Either<Failure, bool>> call(String downloadId) async {
    return await repository.deleteDownload(downloadId);
  }
}

class GetAllDownloads {
  final DownloadRepository repository;

  GetAllDownloads(this.repository);

  Future<Either<Failure, List<DownloadItem>>> call() async {
    return await repository.getAllDownloads();
  }
}

class IsVideoDownloaded {
  final DownloadRepository repository;

  IsVideoDownloaded(this.repository);

  Future<Either<Failure, bool>> call(String videoId) async {
    return await repository.isVideoDownloaded(videoId);
  }
}

class GetLocalVideoPath {
  final DownloadRepository repository;

  GetLocalVideoPath(this.repository);

  Future<Either<Failure, String?>> call(String videoId) async {
    return await repository.getLocalVideoPath(videoId);
  }
}

class GetCompletedDownloads {
  final DownloadRepository repository;

  GetCompletedDownloads(this.repository);

  Future<Either<Failure, List<DownloadItem>>> call() async {
    return await repository.getCompletedDownloads();
  }
}

class GetActiveDownloads {
  final DownloadRepository repository;

  GetActiveDownloads(this.repository);

  Future<Either<Failure, List<DownloadItem>>> call() async {
    return await repository.getActiveDownloads();
  }
}

class GetDownloadByVideoId {
  final DownloadRepository repository;

  GetDownloadByVideoId(this.repository);

  Future<Either<Failure, DownloadItem?>> call(String videoId) async {
    return await repository.getDownloadByVideoId(videoId);
  }
}