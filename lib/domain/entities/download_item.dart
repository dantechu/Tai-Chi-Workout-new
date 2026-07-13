import 'package:equatable/equatable.dart';

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  paused,
  cancelled,
}

class DownloadItem extends Equatable {
  final String id;
  final String videoId;
  final String url;
  final String localPath;
  final DownloadStatus status;
  final double progress;
  final int totalBytes;
  final int downloadedBytes;
  final String? error;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;
  final String? title;
  final String? mediaType; // 'video' or 'audio'

  const DownloadItem({
    required this.id,
    required this.videoId,
    required this.url,
    required this.localPath,
    required this.status,
    this.progress = 0.0,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.error,
    this.startedAt,
    this.completedAt,
    this.updatedAt,
    this.title,
    this.mediaType,
  });

  bool get isCompleted => status == DownloadStatus.completed;
  bool get isDownloading => status == DownloadStatus.downloading;
  bool get isFailed => status == DownloadStatus.failed;
  bool get isPending => status == DownloadStatus.pending;
  bool get isPaused => status == DownloadStatus.paused;
  bool get isCancelled => status == DownloadStatus.cancelled;

  String get statusDisplayName {
    switch (status) {
      case DownloadStatus.pending:
        return 'Pending';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }

  Duration? get downloadDuration {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  double get downloadSpeed {
    final duration = downloadDuration;
    if (duration == null || duration.inSeconds == 0) return 0.0;
    return downloadedBytes / duration.inSeconds; // bytes per second
  }

  String get downloadSpeedFormatted {
    final speed = downloadSpeed;
    if (speed < 1024) return '${speed.toInt()} B/s';
    if (speed < 1024 * 1024) return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  Duration? get estimatedTimeRemaining {
    if (!isDownloading || downloadSpeed <= 0) return null;
    final remainingBytes = totalBytes - downloadedBytes;
    final secondsRemaining = remainingBytes / downloadSpeed;
    return Duration(seconds: secondsRemaining.ceil());
  }

  DownloadItem copyWith({
    String? id,
    String? videoId,
    String? url,
    String? localPath,
    DownloadStatus? status,
    double? progress,
    int? totalBytes,
    int? downloadedBytes,
    String? error,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    String? title,
    String? mediaType,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      error: error ?? this.error,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      mediaType: mediaType ?? this.mediaType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        videoId,
        url,
        localPath,
        status,
        progress,
        totalBytes,
        downloadedBytes,
        error,
        startedAt,
        completedAt,
        updatedAt,
        title,
        mediaType,
      ];

  @override
  String toString() {
    return 'DownloadItem(id: $id, videoId: $videoId, status: $status, progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}