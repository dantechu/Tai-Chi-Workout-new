import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

/// A singleton service that caches video thumbnails in memory
class ThumbnailCacheService {
  static final ThumbnailCacheService _instance = ThumbnailCacheService._internal();
  factory ThumbnailCacheService() => _instance;
  ThumbnailCacheService._internal();

  final Map<String, Uint8List> _cache = {};
  final Map<String, Future<Uint8List?>> _pendingRequests = {};

  /// Check if thumbnail is cached
  bool hasCached(String videoUrl) => _cache.containsKey(videoUrl);

  /// Get cached thumbnail
  Uint8List? getCached(String videoUrl) => _cache[videoUrl];

  /// Get or extract thumbnail from video URL
  /// Returns cached version if available, otherwise extracts and caches
  Future<Uint8List?> getThumbnail(String videoUrl) async {
    // Return cached if available
    if (_cache.containsKey(videoUrl)) {
      return _cache[videoUrl];
    }

    // If there's already a pending request for this URL, wait for it
    if (_pendingRequests.containsKey(videoUrl)) {
      return _pendingRequests[videoUrl];
    }

    // Create new request
    final future = _extractThumbnail(videoUrl);
    _pendingRequests[videoUrl] = future;

    try {
      final thumbnail = await future;
      if (thumbnail != null) {
        _cache[videoUrl] = thumbnail;
      }
      return thumbnail;
    } finally {
      _pendingRequests.remove(videoUrl);
    }
  }

  Future<Uint8List?> _extractThumbnail(String videoUrl) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 75,
      );
      return thumbnail;
    } catch (e) {
      return null;
    }
  }

  /// Clear all cached thumbnails
  void clearCache() {
    _cache.clear();
  }

  /// Remove specific thumbnail from cache
  void removeFromCache(String videoUrl) {
    _cache.remove(videoUrl);
  }

  /// Get cache size (number of cached thumbnails)
  int get cacheSize => _cache.length;
}
