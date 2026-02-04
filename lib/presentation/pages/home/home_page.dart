import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../bloc/video/video_bloc.dart';
import '../../bloc/video/video_state.dart';
import '../../bloc/video/video_event.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../../bloc/premium/premium_state.dart';
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
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTimeBasedGreeting(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.readyForTaiChi ?? 'Ready for Tai Chi?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.self_improvement,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.searchVideos ?? 'Search videos...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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

        return Container(
          height: 44,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  label: category,
                  isSelected: _selectedCategory == category,
                  onTap: () => _selectCategory(category),
                ),
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
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.videoLoadError ?? 'Error loading videos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      videoState.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.read<VideoBloc>().add(const LoadVideos());
                      },
                      child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)?.noResults ?? 'No videos found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.tryAdjustingFilter ?? 'Try adjusting your search or category filter',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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