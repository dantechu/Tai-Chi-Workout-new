import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_local_datasource.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkLocalDataSource localDataSource;

  BookmarkRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Bookmark>>> getAllBookmarks() async {
    try {
      final result = await localDataSource.getAllBookmarks();
      return Right(result.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get bookmarks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addBookmark(String videoId) async {
    try {
      await localDataSource.addBookmark(videoId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to add bookmark: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String videoId) async {
    try {
      await localDataSource.removeBookmark(videoId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to remove bookmark: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isVideoBookmarked(String videoId) async {
    try {
      final result = await localDataSource.isVideoBookmarked(videoId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to check bookmark status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleBookmark(String videoId) async {
    try {
      final isBookmarked = await localDataSource.isVideoBookmarked(videoId);
      if (isBookmarked) {
        await localDataSource.removeBookmark(videoId);
      } else {
        await localDataSource.addBookmark(videoId);
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to toggle bookmark: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllBookmarks() async {
    try {
      await localDataSource.clearAllBookmarks();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to clear bookmarks: ${e.toString()}'));
    }
  }
}
