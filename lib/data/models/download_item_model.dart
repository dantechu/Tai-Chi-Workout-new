import '../../domain/entities/download_item.dart';

class DownloadItemModel {
  final String id;
  final String videoId;
  final String url;
  final String localPath;
  final String status;
  final double progress;
  final int totalBytes;
  final int downloadedBytes;
  final String? error;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;
  final String? title;
  final String? mediaType; // 'video' or 'audio'

  const DownloadItemModel({
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

  factory DownloadItemModel.fromEntity(DownloadItem entity) {
    return DownloadItemModel(
      id: entity.id,
      videoId: entity.videoId,
      url: entity.url,
      localPath: entity.localPath,
      status: entity.status.name,
      progress: entity.progress,
      totalBytes: entity.totalBytes,
      downloadedBytes: entity.downloadedBytes,
      error: entity.error,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      updatedAt: entity.updatedAt,
      title: entity.title,
      mediaType: entity.mediaType,
    );
  }

  DownloadItem toEntity() {
    return DownloadItem(
      id: id,
      videoId: videoId,
      url: url,
      localPath: localPath,
      status: _statusFromString(status),
      progress: progress,
      totalBytes: totalBytes,
      downloadedBytes: downloadedBytes,
      error: error,
      startedAt: startedAt,
      completedAt: completedAt,
      updatedAt: updatedAt,
      title: title,
      mediaType: mediaType,
    );
  }

  factory DownloadItemModel.fromJson(Map<String, dynamic> json) {
    return DownloadItemModel(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      url: json['url'] as String,
      localPath: json['localPath'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      totalBytes: json['totalBytes'] as int? ?? 0,
      downloadedBytes: json['downloadedBytes'] as int? ?? 0,
      error: json['error'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      title: json['title'] as String?,
      mediaType: json['mediaType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'url': url,
      'localPath': localPath,
      'status': status,
      'progress': progress,
      'totalBytes': totalBytes,
      'downloadedBytes': downloadedBytes,
      'error': error,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'title': title,
      'mediaType': mediaType,
    };
  }

  DownloadItemModel copyWith({
    String? id,
    String? videoId,
    String? url,
    String? localPath,
    String? status,
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
    return DownloadItemModel(
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

  static DownloadStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DownloadStatus.pending;
      case 'downloading':
        return DownloadStatus.downloading;
      case 'completed':
        return DownloadStatus.completed;
      case 'failed':
        return DownloadStatus.failed;
      case 'paused':
        return DownloadStatus.paused;
      case 'cancelled':
        return DownloadStatus.cancelled;
      default:
        return DownloadStatus.pending;
    }
  }
}
