import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideos extends VideoEvent {
  const LoadVideos();
}

class LoadVideosByCategory extends VideoEvent {
  final String category;

  const LoadVideosByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class SearchVideos extends VideoEvent {
  final String query;

  const SearchVideos(this.query);

  @override
  List<Object> get props => [query];
}

class SearchVideosByCategory extends VideoEvent {
  final String query;
  final String category;

  const SearchVideosByCategory(this.query, this.category);

  @override
  List<Object> get props => [query, category];
}

class FilterVideos extends VideoEvent {
  final bool showOnlyFree;
  final bool showOnlyPremium;

  const FilterVideos({
    this.showOnlyFree = false,
    this.showOnlyPremium = false,
  });

  @override
  List<Object> get props => [showOnlyFree, showOnlyPremium];
}

class RefreshVideos extends VideoEvent {
  const RefreshVideos();
}

class ClearSearch extends VideoEvent {
  const ClearSearch();
}

class UpdateFilters extends VideoEvent {
  final String? searchQuery;
  final String? selectedCategory;

  const UpdateFilters({
    this.searchQuery,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [searchQuery, selectedCategory];
}

class SearchVideosAcrossCourses extends VideoEvent {
  final String query;

  const SearchVideosAcrossCourses(this.query);

  @override
  List<Object> get props => [query];
}