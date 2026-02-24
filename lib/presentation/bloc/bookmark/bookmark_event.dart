import 'package:equatable/equatable.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookmarks extends BookmarkEvent {
  const LoadBookmarks();
}

class AddBookmark extends BookmarkEvent {
  final String videoId;

  const AddBookmark(this.videoId);

  @override
  List<Object> get props => [videoId];
}

class RemoveBookmark extends BookmarkEvent {
  final String videoId;

  const RemoveBookmark(this.videoId);

  @override
  List<Object> get props => [videoId];
}

class ToggleBookmark extends BookmarkEvent {
  final String videoId;

  const ToggleBookmark(this.videoId);

  @override
  List<Object> get props => [videoId];
}

class CheckBookmarkStatus extends BookmarkEvent {
  final String videoId;

  const CheckBookmarkStatus(this.videoId);

  @override
  List<Object> get props => [videoId];
}

class ClearAllBookmarks extends BookmarkEvent {
  const ClearAllBookmarks();
}
