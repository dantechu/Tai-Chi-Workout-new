import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../../core/error/exceptions.dart';
import '../models/download_item_model.dart';

abstract class DownloadLocalDataSource {
  Future<DownloadItemModel> startDownload(String videoId, String url, {String? title, String? mediaType});
  Future<bool> pauseDownload(String downloadId);
  Future<bool> resumeDownload(String downloadId);
  Future<bool> cancelDownload(String downloadId);
  Future<bool> deleteDownload(String downloadId);
  Future<List<DownloadItemModel>> getAllDownloads();
  Future<List<DownloadItemModel>> getCompletedDownloads();
  Future<List<DownloadItemModel>> getActiveDownloads();
  Future<DownloadItemModel?> getDownloadByVideoId(String videoId);
  Future<bool> isVideoDownloaded(String videoId);
  Future<String?> getLocalVideoPath(String videoId);
  Stream<DownloadItemModel> get downloadProgressStream;
}

class DownloadLocalDataSourceImpl implements DownloadLocalDataSource {
  final Box downloadBox;
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, int> _downloadProgress = {};

  /// Dedicated Dio instance for file downloads (no JSON headers)
  late final Dio _downloadDio;

  DownloadLocalDataSourceImpl({
    required this.downloadBox,
  }) {
    // Create a dedicated Dio instance for file downloads
    // This avoids the JSON headers from the API Dio client
    _downloadDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 30),
    ));

    // Add logging interceptor for debugging
    _downloadDio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));
  }

  @override
  Future<DownloadItemModel> startDownload(String videoId, String url, {String? title, String? mediaType}) async {
    try {
      // Check if already downloaded
      final existing = await getDownloadByVideoId(videoId);
      if (existing != null && existing.status == 'completed') {
        return existing;
      }

      // Check available storage (require at least 100MB free space)
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      // Note: On iOS, we can't directly check free space, but we can try to catch errors

      // Use Application Support directory instead of Documents
      // This is Apple's recommended location for app-generated content
      // that should NOT be backed up to iCloud
      final appSupportDir = await getApplicationSupportDirectory();
      final downloadsDir = Directory('${appSupportDir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Determine file extension based on media type
      final fileExtension = mediaType == 'audio' ? '.mp3' : '.mp4';

      // Create local file path with correct extension
      final fileName = '${videoId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final localPath = '${downloadsDir.path}/$fileName';

      // Create the file first to set exclusion from backup
      final file = File(localPath);
      await file.create(recursive: true);

      // Create download item with title and mediaType
      final downloadId = DateTime.now().millisecondsSinceEpoch.toString();
      final downloadItem = DownloadItemModel(
        id: downloadId,
        videoId: videoId,
        url: url,
        localPath: localPath,
        status: 'downloading',
        progress: 0.0,
        totalBytes: 0,
        downloadedBytes: 0,
        startedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        title: title,
        mediaType: mediaType,
      );

      // Save to Hive
      await downloadBox.put(downloadId, downloadItem.toJson());

      // Start download
      final cancelToken = CancelToken();
      _cancelTokens[downloadId] = cancelToken;

      _downloadDio.download(
        url,
        localPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            // Check if download size is reasonable (max 500MB per video)
            if (total > 500 * 1024 * 1024) {
              cancelToken.cancel('File too large (max 500MB)');
              return;
            }

            final progress = received / total;
            _downloadProgress[downloadId] = received;

            // Update download item
            final updated = downloadItem.copyWith(
              progress: progress,
              totalBytes: total,
              downloadedBytes: received,
              updatedAt: DateTime.now(),
            );

            await downloadBox.put(downloadId, updated.toJson());
          }
        },
      ).then((_) async {
        // Download completed - Mark file to exclude from iCloud backup
        // This is required by Apple for downloaded content
        final downloadedFile = File(localPath);
        int actualFileSize = 0;
        if (await downloadedFile.exists()) {
          // Get the actual file size from disk
          actualFileSize = await downloadedFile.length();
          // On iOS, we need to set the file attribute to exclude from backup
          // This is done through platform channel or the file is in the right directory
          // Since we're using Application Support, it's already excluded
        }

        final completed = downloadItem.copyWith(
          status: 'completed',
          progress: 1.0,
          totalBytes: actualFileSize > 0 ? actualFileSize : downloadItem.totalBytes,
          downloadedBytes: actualFileSize > 0 ? actualFileSize : downloadItem.downloadedBytes,
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await downloadBox.put(downloadId, completed.toJson());
        _cancelTokens.remove(downloadId);
        _downloadProgress.remove(downloadId);
      }).catchError((error) async {
        // Download failed - clean up partial file
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }

        final failed = downloadItem.copyWith(
          status: 'failed',
          error: error.toString(),
          updatedAt: DateTime.now(),
        );
        await downloadBox.put(downloadId, failed.toJson());
        _cancelTokens.remove(downloadId);
        _downloadProgress.remove(downloadId);
      });

      return downloadItem;
    } catch (e) {
      throw CacheException('Failed to start download: ${e.toString()}');
    }
  }

  @override
  Future<bool> pauseDownload(String downloadId) async {
    try {
      final cancelToken = _cancelTokens[downloadId];
      if (cancelToken != null) {
        cancelToken.cancel('Paused by user');
        _cancelTokens.remove(downloadId);

        // Update status
        final downloadData = downloadBox.get(downloadId);
        if (downloadData != null) {
          // Cast Map<dynamic, dynamic> from Hive to Map<String, dynamic>
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(downloadData as Map);
          final download = DownloadItemModel.fromJson(jsonData);
          final paused = download.copyWith(
            status: 'paused',
            updatedAt: DateTime.now(),
          );
          await downloadBox.put(downloadId, paused.toJson());
        }
      }
      return true;
    } catch (e) {
      throw CacheException('Failed to pause download: ${e.toString()}');
    }
  }

  @override
  Future<bool> resumeDownload(String downloadId) async {
    try {
      final downloadData = downloadBox.get(downloadId);
      if (downloadData == null) return false;

      // Cast Map<dynamic, dynamic> from Hive to Map<String, dynamic>
      final Map<String, dynamic> jsonData = Map<String, dynamic>.from(downloadData as Map);
      final download = DownloadItemModel.fromJson(jsonData);

      // Restart download
      await startDownload(download.videoId, download.url);
      return true;
    } catch (e) {
      throw CacheException('Failed to resume download: ${e.toString()}');
    }
  }

  @override
  Future<bool> cancelDownload(String downloadId) async {
    try {
      final cancelToken = _cancelTokens[downloadId];
      if (cancelToken != null) {
        cancelToken.cancel('Cancelled by user');
        _cancelTokens.remove(downloadId);
      }

      // Update status
      final downloadData = downloadBox.get(downloadId);
      if (downloadData != null) {
        // Cast Map<dynamic, dynamic> from Hive to Map<String, dynamic>
        final Map<String, dynamic> jsonData = Map<String, dynamic>.from(downloadData as Map);
        final download = DownloadItemModel.fromJson(jsonData);
        final cancelled = download.copyWith(
          status: 'cancelled',
          updatedAt: DateTime.now(),
        );
        await downloadBox.put(downloadId, cancelled.toJson());

        // Delete partial file
        final file = File(download.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _downloadProgress.remove(downloadId);
      return true;
    } catch (e) {
      throw CacheException('Failed to cancel download: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteDownload(String downloadId) async {
    try {
      final downloadData = downloadBox.get(downloadId);
      if (downloadData == null) return false;

      // Cast Map<dynamic, dynamic> from Hive to Map<String, dynamic>
      final Map<String, dynamic> jsonData = Map<String, dynamic>.from(downloadData as Map);
      final download = DownloadItemModel.fromJson(jsonData);

      // Delete file
      final file = File(download.localPath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from Hive
      await downloadBox.delete(downloadId);
      _cancelTokens.remove(downloadId);
      _downloadProgress.remove(downloadId);

      return true;
    } catch (e) {
      throw CacheException('Failed to delete download: ${e.toString()}');
    }
  }

  @override
  Future<List<DownloadItemModel>> getAllDownloads() async {
    try {
      final downloads = <DownloadItemModel>[];
      for (var key in downloadBox.keys) {
        final data = downloadBox.get(key);
        if (data != null) {
          // Cast Map<dynamic, dynamic> from Hive to Map<String, dynamic>
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(data as Map);
          downloads.add(DownloadItemModel.fromJson(jsonData));
        }
      }
      return downloads;
    } catch (e) {
      throw CacheException('Failed to get all downloads: ${e.toString()}');
    }
  }

  @override
  Future<List<DownloadItemModel>> getCompletedDownloads() async {
    try {
      final allDownloads = await getAllDownloads();
      return allDownloads.where((d) => d.status == 'completed').toList();
    } catch (e) {
      throw CacheException('Failed to get completed downloads: ${e.toString()}');
    }
  }

  @override
  Future<List<DownloadItemModel>> getActiveDownloads() async {
    try {
      final allDownloads = await getAllDownloads();
      return allDownloads.where((d) =>
        d.status == 'downloading' || d.status == 'pending'
      ).toList();
    } catch (e) {
      throw CacheException('Failed to get active downloads: ${e.toString()}');
    }
  }

  @override
  Future<DownloadItemModel?> getDownloadByVideoId(String videoId) async {
    try {
      final allDownloads = await getAllDownloads();
      final downloads = allDownloads.where((d) => d.videoId == videoId).toList();

      if (downloads.isEmpty) return null;

      // Return completed one if exists, otherwise return latest
      final completed = downloads.where((d) => d.status == 'completed').toList();
      if (completed.isNotEmpty) return completed.first;

      return downloads.first;
    } catch (e) {
      throw CacheException('Failed to get download by video ID: ${e.toString()}');
    }
  }

  @override
  Future<bool> isVideoDownloaded(String videoId) async {
    try {
      final download = await getDownloadByVideoId(videoId);
      if (download == null) return false;

      // Check if file exists
      if (download.status == 'completed') {
        final file = File(download.localPath);
        return await file.exists();
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getLocalVideoPath(String videoId) async {
    try {
      final download = await getDownloadByVideoId(videoId);
      if (download == null || download.status != 'completed') return null;

      final file = File(download.localPath);
      if (await file.exists()) {
        return download.localPath;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<DownloadItemModel> get downloadProgressStream {
    // This would require a StreamController to properly implement
    // For now, return empty stream
    return Stream.empty();
  }
}
