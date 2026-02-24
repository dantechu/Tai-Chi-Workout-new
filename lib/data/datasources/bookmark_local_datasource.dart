import 'package:hive/hive.dart';
import '../../core/error/exceptions.dart';
import '../models/bookmark_model.dart';

abstract class BookmarkLocalDataSource {
  Future<List<BookmarkModel>> getAllBookmarks();
  Future<void> addBookmark(String videoId);
  Future<void> removeBookmark(String videoId);
  Future<bool> isVideoBookmarked(String videoId);
  Future<void> clearAllBookmarks();
}

class BookmarkLocalDataSourceImpl implements BookmarkLocalDataSource {
  static const String bookmarkBoxName = 'bookmarks_cache';

  @override
  Future<List<BookmarkModel>> getAllBookmarks() async {
    try {
      final box = await Hive.openBox<Map>(bookmarkBoxName);
      final bookmarks = <BookmarkModel>[];

      for (final bookmarkMap in box.values) {
        final typedMap = Map<String, dynamic>.from(bookmarkMap);
        bookmarks.add(BookmarkModel.fromJson(typedMap));
      }

      // Sort by createdAt descending (most recent first)
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return bookmarks;
    } catch (e) {
      throw CacheException('Failed to get bookmarks: $e');
    }
  }

  @override
  Future<void> addBookmark(String videoId) async {
    try {
      final box = await Hive.openBox<Map>(bookmarkBoxName);

      // Check if already bookmarked
      if (box.containsKey(videoId)) {
        return;
      }

      final bookmark = BookmarkModel.create(videoId);
      await box.put(videoId, bookmark.toJson());
    } catch (e) {
      throw CacheException('Failed to add bookmark: $e');
    }
  }

  @override
  Future<void> removeBookmark(String videoId) async {
    try {
      final box = await Hive.openBox<Map>(bookmarkBoxName);
      await box.delete(videoId);
    } catch (e) {
      throw CacheException('Failed to remove bookmark: $e');
    }
  }

  @override
  Future<bool> isVideoBookmarked(String videoId) async {
    try {
      final box = await Hive.openBox<Map>(bookmarkBoxName);
      return box.containsKey(videoId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAllBookmarks() async {
    try {
      final box = await Hive.openBox<Map>(bookmarkBoxName);
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear bookmarks: $e');
    }
  }
}
