import 'package:equatable/equatable.dart';
import '../../../domain/entities/video.dart';

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {
  const VideoInitial();
}

class VideoLoading extends VideoState {
  const VideoLoading();
}

class VideoLoaded extends VideoState {
  final List<Video> videos;
  final String? selectedCategory;
  final String? searchQuery;
  final bool showOnlyFree;
  final bool showOnlyPremium;

  const VideoLoaded({
    required this.videos,
    this.selectedCategory,
    this.searchQuery,
    this.showOnlyFree = false,
    this.showOnlyPremium = false,
  });

  bool _isAllCategory(String? category) {
    if (category == null || category.isEmpty) return true;
    
    // Check for "All" in various languages
    final allVariants = ['all', 'alle', 'todo', 'tout', 'すべて', '全部', '전체'];
    return allVariants.contains(category.toLowerCase());
  }

  List<Video> get filteredVideos {
    var filtered = videos;

    // Apply category filter (skip if "All" or equivalent)
    if (!_isAllCategory(selectedCategory)) {
      filtered = filtered.where((video) => 
        video.category.toLowerCase() == selectedCategory!.toLowerCase()
      ).toList();
    }

    // Apply search filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filtered = filtered.where((video) =>
        video.title.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        video.category.toLowerCase().contains(searchQuery!.toLowerCase()) ||
        (video.description?.toLowerCase().contains(searchQuery!.toLowerCase()) ?? false)
      ).toList();
    }

    // Apply premium filter
    if (showOnlyFree) {
      filtered = filtered.where((video) => !video.isPremium).toList();
    } else if (showOnlyPremium) {
      filtered = filtered.where((video) => video.isPremium).toList();
    }

    return filtered;
  }

  List<String> get categories {
    final categories = videos.map((video) => video.category).toSet().toList();
    categories.sort();
    return categories;
  }

  @override
  List<Object?> get props => [
    videos,
    selectedCategory,
    searchQuery,
    showOnlyFree,
    showOnlyPremium,
  ];

  VideoLoaded copyWith({
    List<Video>? videos,
    String? selectedCategory,
    String? searchQuery,
    bool? showOnlyFree,
    bool? showOnlyPremium,
    bool clearSearchQuery = false,
    bool clearSelectedCategory = false,
  }) {
    return VideoLoaded(
      videos: videos ?? this.videos,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      showOnlyFree: showOnlyFree ?? this.showOnlyFree,
      showOnlyPremium: showOnlyPremium ?? this.showOnlyPremium,
    );
  }
}

class VideoError extends VideoState {
  final String message;

  const VideoError(this.message);

  @override
  List<Object> get props => [message];
}