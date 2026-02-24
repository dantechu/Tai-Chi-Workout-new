import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/bookmark.dart';

abstract class BookmarkRepository {
  Future<Either<Failure, List<Bookmark>>> getAllBookmarks();
  Future<Either<Failure, void>> addBookmark(String videoId);
  Future<Either<Failure, void>> removeBookmark(String videoId);
  Future<Either<Failure, bool>> isVideoBookmarked(String videoId);
  Future<Either<Failure, void>> toggleBookmark(String videoId);
  Future<Either<Failure, void>> clearAllBookmarks();
}
