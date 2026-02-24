import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../bloc/video/video_bloc.dart';
import '../../bloc/video/video_state.dart';
import '../../bloc/video/video_event.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../../bloc/premium/premium_state.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../../courses/bloc/courses_state.dart';
import '../../widgets/video_card.dart';
import '../../widgets/category_chip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<VideoBloc>().add(const LoadVideos());
    context.read<CoursesBloc>().add(const LoadSelectedCourse());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoursesBloc, CoursesState>(
      listener: (context, state) {
        // Reload videos when a new course is selected
        if (state is CourseSelected || state is SelectedCourseLoaded) {
          // Reset category filter when course changes
          setState(() {
            _selectedCategory = 'All';
            _searchQuery = '';
            _searchController.clear();
          });
          context.read<VideoBloc>().add(const LoadVideos());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCategoryFilter(),
              Expanded(
                child: _buildVideoList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 12) {
      return AppLocalizations.of(context)?.goodMorning ?? 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return AppLocalizations.of(context)?.goodAfternoon ?? 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return AppLocalizations.of(context)?.goodEvening ?? 'Good Evening';
    } else {
      return AppLocalizations.of(context)?.goodNight ?? 'Good Night';
    }
  }

  Widget _buildHeader() {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        String courseName = '';
        if (state is SelectedCourseLoaded) {
          courseName = state.course.name;
        } else if (state is CoursesLoaded && state.selectedCourse != null) {
          courseName = state.selectedCourse!.name;
        } else if (state is CourseSelected) {
          courseName = state.course.name;
        }

        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTimeBasedGreeting(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      courseName.isNotEmpty ? courseName : (AppLocalizations.of(context)?.readyForTaiChi ?? 'Ready for Tai Chi?'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: -0.3,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.self_improvement_rounded,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 15,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.searchVideos ?? 'Search videos...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
          _debounceTimer?.cancel();
          
          // For immediate clearing when text becomes empty
          if (query.isEmpty) {
            _performSearch();
          } else {
            _debounceTimer = Timer(const Duration(milliseconds: 150), () {
              _performSearch();
            });
          }
        },
        onSubmitted: (query) {
          setState(() {
            _searchQuery = query;
          });
          _debounceTimer?.cancel();
          _performSearch();
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        List<String> categoryTitles = [];

        // Extract unique categories from loaded videos
        if (state is VideoLoaded) {
          final uniqueCategories = state.videos
              .map((video) => video.category)
              .where((category) => category.isNotEmpty)
              .toSet()
              .toList();
          categoryTitles = uniqueCategories;
        }

        final categories = [AppLocalizations.of(context)?.all ?? 'All', ...categoryTitles];

        return SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryChip(
                label: category,
                isSelected: _selectedCategory == category,
                onTap: () => _selectCategory(category),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVideoList() {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, videoState) {
        return BlocBuilder<PremiumBloc, PremiumState>(
          builder: (context, premiumState) {
            if (videoState is VideoLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (videoState is VideoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)?.videoLoadError ?? 'Error loading videos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      videoState.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<VideoBloc>().add(const LoadVideos());
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (videoState is VideoLoaded) {
              if (videoState.filteredVideos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)?.noResults ?? 'No videos found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)?.tryAdjustingFilter ?? 'Try adjusting your search or category filter',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: videoState.filteredVideos.length,
                itemBuilder: (context, index) {
                  final video = videoState.filteredVideos[index];
                  final isPremium = premiumState is PremiumActive;

                  return VideoCard(
                    video: video,
                    isPremiumUser: isPremium,
                    onTap: () => _navigateToVideoPlayer(video),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  void _performSearch() {
    // If videos aren't loaded yet, load them first
    if (context.read<VideoBloc>().state is! VideoLoaded) {
      context.read<VideoBloc>().add(const LoadVideos());
      return;
    }
    
    context.read<VideoBloc>().add(UpdateFilters(
      searchQuery: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
      selectedCategory: _selectedCategory,
    ));
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _performSearch();
  }

  void _navigateToVideoPlayer(video) {
    // Check if video is premium and user doesn't have premium access
    final premiumState = context.read<PremiumBloc>().state;
    final hasPremiumAccess = premiumState is PremiumActive;

    if (video.isPremium && !hasPremiumAccess) {
      // Navigate to premium unlock screen
      Navigator.of(context).pushNamed('/premium');
    } else {
      // Navigate to video player
      Navigator.of(context).pushNamed(
        '/video-player',
        arguments: video,
      );
    }
  }
}