import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../../core/error/exceptions.dart';
import '../models/download_item_model.dart';

abstract class DownloadLocalDataSource {
  Future<DownloadItemModel> startDownload(String videoId, String url);
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
  final Dio dio;
  final Box downloadBox;
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, int> _downloadProgress = {};

  DownloadLocalDataSourceImpl({
    required this.dio,
    required this.downloadBox,
  });

  @override
  Future<DownloadItemModel> startDownload(String videoId, String url) async {
    try {
      // Check if already downloaded
      final existing = await getDownloadByVideoId(videoId);
      if (existing != null && existing.status == 'completed') {
        return existing;
      }

      // Get downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Create local file path
      final fileName = '${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final localPath = '${downloadsDir.path}/$fileName';

      // Create download item
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
      );

      // Save to Hive
      await downloadBox.put(downloadId, downloadItem.toJson());

      // Start download
      final cancelToken = CancelToken();
      _cancelTokens[downloadId] = cancelToken;

      dio.download(
        url,
        localPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
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
        // Download completed
        final completed = downloadItem.copyWith(
          status: 'completed',
          progress: 1.0,
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await downloadBox.put(downloadId, completed.toJson());
        _cancelTokens.remove(downloadId);
        _downloadProgress.remove(downloadId);
      }).catchError((error) async {
        // Download failed
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
        final downloadData = await downloadBox.get(downloadId);
        if (downloadData != null) {
          final download = DownloadItemModel.fromJson(downloadData);
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
      final downloadData = await downloadBox.get(downloadId);
      if (downloadData == null) return false;

      final download = DownloadItemModel.fromJson(downloadData);

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
      final downloadData = await downloadBox.get(downloadId);
      if (downloadData != null) {
        final download = DownloadItemModel.fromJson(downloadData);
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
      final downloadData = await downloadBox.get(downloadId);
      if (downloadData == null) return false;

      final download = DownloadItemModel.fromJson(downloadData);

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
        final data = await downloadBox.get(key);
        if (data != null) {
          downloads.add(DownloadItemModel.fromJson(data));
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
