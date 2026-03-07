import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_videos.dart' as usecases;
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final usecases.GetVideos getVideos;
  final usecases.GetVideosByCategory getVideosByCategory;
  final usecases.SearchVideos searchVideos;
  final usecases.SearchVideosAcrossAllCourses searchVideosAcrossAllCourses;

  VideoBloc({
    required this.getVideos,
    required this.getVideosByCategory,
    required this.searchVideos,
    required this.searchVideosAcrossAllCourses,
  }) : super(const VideoInitial()) {
    on<LoadVideos>(_onLoadVideos);
    on<LoadVideosByCategory>(_onLoadVideosByCategory);
    on<SearchVideos>(_onSearchVideos);
    on<SearchVideosByCategory>(_onSearchVideosByCategory);
    on<FilterVideos>(_onFilterVideos);
    on<RefreshVideos>(_onRefreshVideos);
    on<ClearSearch>(_onClearSearch);
    on<UpdateFilters>(_onUpdateFilters);
    on<SearchVideosAcrossCourses>(_onSearchVideosAcrossCourses);
  }

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideoState> emit) async {
    emit(const VideoLoading());

    final result = await getVideos();
    result.fold(
      (failure) => emit(VideoError(failure.message)),
      (videos) => emit(VideoLoaded(videos: videos)),
    );
  }

  Future<void> _onLoadVideosByCategory(
    LoadVideosByCategory event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      emit(currentState.copyWith(selectedCategory: event.category));
    } else {
      // If no videos are loaded yet, load all videos first
      emit(const VideoLoading());
      final result = await getVideos();
      result.fold(
        (failure) => emit(VideoError(failure.message)),
        (videos) => emit(VideoLoaded(
          videos: videos,
          selectedCategory: event.category,
        )),
      );
    }
  }

  Future<void> _onSearchVideos(
    SearchVideos event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    } else {
      // If no videos are loaded yet, load all videos first
      emit(const VideoLoading());
      final result = await getVideos();
      result.fold(
        (failure) => emit(VideoError(failure.message)),
        (videos) => emit(VideoLoaded(
          videos: videos,
          searchQuery: event.query,
        )),
      );
    }
  }

  Future<void> _onSearchVideosByCategory(
    SearchVideosByCategory event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      emit(currentState.copyWith(
        searchQuery: event.query,
        selectedCategory: event.category,
      ));
    } else {
      // If no videos are loaded yet, load all videos first
      emit(const VideoLoading());
      final result = await getVideos();
      result.fold(
        (failure) => emit(VideoError(failure.message)),
        (videos) => emit(VideoLoaded(
          videos: videos,
          searchQuery: event.query,
          selectedCategory: event.category,
        )),
      );
    }
  }

  void _onFilterVideos(FilterVideos event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      emit(currentState.copyWith(
        showOnlyFree: event.showOnlyFree,
        showOnlyPremium: event.showOnlyPremium,
      ));
    }
  }

  Future<void> _onRefreshVideos(
    RefreshVideos event,
    Emitter<VideoState> emit,
  ) async {
    // Keep current filters but reload videos
    String? currentCategory;
    String? currentQuery;
    bool currentShowOnlyFree = false;
    bool currentShowOnlyPremium = false;

    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      currentCategory = currentState.selectedCategory;
      currentQuery = currentState.searchQuery;
      currentShowOnlyFree = currentState.showOnlyFree;
      currentShowOnlyPremium = currentState.showOnlyPremium;
    }

    emit(const VideoLoading());

    final result = await getVideos();
    result.fold(
      (failure) => emit(VideoError(failure.message)),
      (videos) => emit(VideoLoaded(
        videos: videos,
        selectedCategory: currentCategory,
        searchQuery: currentQuery,
        showOnlyFree: currentShowOnlyFree,
        showOnlyPremium: currentShowOnlyPremium,
      )),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      emit(currentState.copyWith(
        clearSearchQuery: true,
        clearSelectedCategory: true,
      ));
    }
  }

  void _onUpdateFilters(UpdateFilters event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      emit(currentState.copyWith(
        searchQuery: event.searchQuery,
        selectedCategory: event.selectedCategory,
        clearSearchQuery: event.searchQuery == null,
        clearSelectedCategory: event.selectedCategory == null,
      ));
    }
  }

  Future<void> _onSearchVideosAcrossCourses(
    SearchVideosAcrossCourses event,
    Emitter<VideoState> emit,
  ) async {
    // Show loading state
    emit(const VideoLoading());

    // Search across all courses
    final result = await searchVideosAcrossAllCourses(event.query);

    result.fold(
      (failure) => emit(VideoError(failure.message)),
      (videos) => emit(VideoLoaded(
        videos: videos,
        searchQuery: event.query,
      )),
    );
  }
}