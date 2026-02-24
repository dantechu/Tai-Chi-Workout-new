import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/bookmark_repository.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final BookmarkRepository bookmarkRepository;

  BookmarkBloc({
    required this.bookmarkRepository,
  }) : super(const BookmarkInitial()) {
    on<LoadBookmarks>(_onLoadBookmarks);
    on<AddBookmark>(_onAddBookmark);
    on<RemoveBookmark>(_onRemoveBookmark);
    on<ToggleBookmark>(_onToggleBookmark);
    on<ClearAllBookmarks>(_onClearAllBookmarks);
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(const BookmarkLoading());

    final result = await bookmarkRepository.getAllBookmarks();
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (bookmarks) => emit(BookmarkLoaded(bookmarks: bookmarks)),
    );
  }

  Future<void> _onAddBookmark(
    AddBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    final result = await bookmarkRepository.addBookmark(event.videoId);
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => add(const LoadBookmarks()),
    );
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    final result = await bookmarkRepository.removeBookmark(event.videoId);
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => add(const LoadBookmarks()),
    );
  }

  Future<void> _onToggleBookmark(
    ToggleBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    final result = await bookmarkRepository.toggleBookmark(event.videoId);
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => add(const LoadBookmarks()),
    );
  }

  Future<void> _onClearAllBookmarks(
    ClearAllBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    final result = await bookmarkRepository.clearAllBookmarks();
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => emit(BookmarkLoaded(bookmarks: [])),
    );
  }
}
