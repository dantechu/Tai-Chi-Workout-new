import 'package:equatable/equatable.dart';
import '../../../domain/entities/bookmark.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {
  const BookmarkInitial();
}

class BookmarkLoading extends BookmarkState {
  const BookmarkLoading();
}

class BookmarkLoaded extends BookmarkState {
  final List<Bookmark> bookmarks;
  final Set<String> bookmarkedVideoIds;

  BookmarkLoaded({
    required this.bookmarks,
    Set<String>? bookmarkedVideoIds,
  }) : bookmarkedVideoIds = bookmarkedVideoIds ??
         bookmarks.map((b) => b.videoId).toSet();

  bool isVideoBookmarked(String videoId) => bookmarkedVideoIds.contains(videoId);

  @override
  List<Object?> get props => [bookmarks, bookmarkedVideoIds];

  BookmarkLoaded copyWith({
    List<Bookmark>? bookmarks,
    Set<String>? bookmarkedVideoIds,
  }) {
    return BookmarkLoaded(
      bookmarks: bookmarks ?? this.bookmarks,
      bookmarkedVideoIds: bookmarkedVideoIds ?? this.bookmarkedVideoIds,
    );
  }
}

class BookmarkError extends BookmarkState {
  final String message;

  const BookmarkError(this.message);

  @override
  List<Object> get props => [message];
}
