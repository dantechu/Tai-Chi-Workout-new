import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/premium_service.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/entities/section.dart';
import '../../../domain/entities/video.dart';
import '../../bloc/bookmark/bookmark_bloc.dart';
import '../../bloc/bookmark/bookmark_state.dart';
import '../../bloc/video/video_bloc.dart';
import '../../bloc/video/video_state.dart';
import '../../bloc/video/video_event.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../../bloc/premium/premium_state.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../../courses/bloc/courses_state.dart';
import '../../courses/pages/course_detail_page.dart';
import '../../widgets/video_card.dart';
import '../../widgets/bookmark_card.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the selected category with the localized "All" string
    if (_selectedCategory == 'All') {
      _selectedCategory = AppLocalizations.of(context)?.all ?? 'All';
    }
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
            _selectedCategory = AppLocalizations.of(context)?.all ?? 'All';
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
        final langCode = LocalizationHelper.getCurrentLanguageCode(context);
        String courseName = '';
        if (state is SelectedCourseLoaded) {
          courseName = state.course.getLocalizedName(langCode);
        } else if (state is CoursesLoaded && state.selectedCourse != null) {
          courseName = state.selectedCourse!.getLocalizedName(langCode);
        } else if (state is CourseSelected) {
          courseName = state.course.getLocalizedName(langCode);
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
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        letterSpacing: -0.2,
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
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, coursesState) {
        // Get sections from the selected course for localization
        List<Section>? sections;
        if (coursesState is SelectedCourseLoaded) {
          sections = coursesState.course.sections;
        } else if (coursesState is CoursesLoaded && coursesState.selectedCourse != null) {
          sections = coursesState.selectedCourse!.sections;
        } else if (coursesState is CourseSelected) {
          sections = coursesState.course.sections;
        }

        final langCode = LocalizationHelper.getCurrentLanguageCode(context);

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

            // Create a mapping of localized to English category names
            final categoryMapping = <String, String>{};
            for (final category in categoryTitles) {
              // Try to find section and get localized title
              String localized = category;
              if (sections != null) {
                final section = sections.where((s) => s.title == category).firstOrNull;
                if (section != null) {
                  localized = section.getLocalizedTitle(langCode);
                } else {
                  localized = LocalizationHelper.getLocalizedCategoryName(context, category);
                }
              } else {
                localized = LocalizationHelper.getLocalizedCategoryName(context, category);
              }
              categoryMapping[localized] = category;
            }

            final localizedCategoryTitles = categoryMapping.keys.toList();
            final allCategory = AppLocalizations.of(context)?.all ?? 'All';
            final categories = [allCategory, ...localizedCategoryTitles];

            return SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  // Get the English category name for filtering
                  final englishCategory = category == allCategory
                      ? allCategory
                      : (categoryMapping[category] ?? category);

                  return CategoryChip(
                    label: category,
                    isSelected: _selectedCategory == englishCategory ||
                                (_selectedCategory == allCategory && category == allCategory),
                    onTap: () => _selectCategory(englishCategory),
                  );
                },
              ),
            );
          },
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

              // Check premium status from singleton service - SINGLE SOURCE OF TRUTH
              final isPremium = PremiumService().isPremium;

              return BlocBuilder<CoursesBloc, CoursesState>(
                builder: (context, coursesState) {
                  // Get sections from the selected course for localization
                  List<Section>? sections;
                  if (coursesState is SelectedCourseLoaded) {
                    sections = coursesState.course.sections;
                  } else if (coursesState is CoursesLoaded && coursesState.selectedCourse != null) {
                    sections = coursesState.selectedCourse!.sections;
                  } else if (coursesState is CourseSelected) {
                    sections = coursesState.course.sections;
                  }

                  return BlocBuilder<BookmarkBloc, BookmarkState>(
                    builder: (context, bookmarkState) {
                      // Get bookmarked videos
                      List<Video> bookmarkedVideos = [];
                      if (bookmarkState is BookmarkLoaded) {
                        bookmarkedVideos = videoState.videos
                            .where((video) => bookmarkState.isVideoBookmarked(video.id))
                            .toList();
                      }

                      return CustomScrollView(
                        slivers: [
                          // Bookmarked videos section
                          if (bookmarkedVideos.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: _buildBookmarksSection(
                                bookmarkedVideos,
                                isPremium,
                                sections,
                              ),
                            ),
                          ],
                          // All videos section header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20,
                                bookmarkedVideos.isNotEmpty ? 8 : 12,
                                20,
                                12,
                              ),
                              child: Text(
                                AppLocalizations.of(context)?.allLessons ?? 'All Lessons',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          // Video list
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final video = videoState.filteredVideos[index];
                                  return VideoCard(
                                    video: video,
                                    isPremiumUser: isPremium,
                                    onTap: () => _navigateToVideoPlayer(video, sections: sections),
                                    sections: sections,
                                  );
                                },
                                childCount: videoState.filteredVideos.length,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
    final query = _searchQuery.trim();
    final allCategory = AppLocalizations.of(context)?.all ?? 'All';

    if (query.isEmpty && _selectedCategory == allCategory) {
      // If search is empty and All category selected, load all videos from selected course
      context.read<VideoBloc>().add(const LoadVideos());
      return;
    }

    if (query.isEmpty && _selectedCategory != allCategory) {
      // If search is empty but category is selected, filter by category
      context.read<VideoBloc>().add(LoadVideosByCategory(_selectedCategory));
      return;
    }

    if (query.isNotEmpty && _selectedCategory == allCategory) {
      // Search across all courses when user types a query
      context.read<VideoBloc>().add(SearchVideosAcrossCourses(query));
      return;
    }

    // Both search query and category selected
    context.read<VideoBloc>().add(SearchVideosByCategory(query, _selectedCategory));
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _performSearch();
  }

  Widget _buildBookmarksSection(List<Video> bookmarkedVideos, bool isPremium, List<Section>? sections) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Icon(
                Icons.bookmark_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Continue Watching',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: bookmarkedVideos.length,
            itemBuilder: (context, index) {
              final video = bookmarkedVideos[index];
              return BookmarkCard(
                video: video,
                isPremiumUser: isPremium,
                onTap: () => _navigateToVideoPlayer(video, sections: sections),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToVideoPlayer(Video video, {List<Section>? sections}) {
    // Get the currently selected course
    final coursesState = context.read<CoursesBloc>().state;
    String? selectedCourseId;
    List<Section>? courseSections = sections;

    if (coursesState is CoursesLoaded && coursesState.selectedCourse != null) {
      selectedCourseId = coursesState.selectedCourse!.id;
      courseSections ??= coursesState.selectedCourse!.sections;
    } else if (coursesState is SelectedCourseLoaded) {
      selectedCourseId = coursesState.course.id;
      courseSections ??= coursesState.course.sections;
    } else if (coursesState is CourseSelected) {
      selectedCourseId = coursesState.course.id;
      courseSections ??= coursesState.course.sections;
    }

    // Check if the video belongs to a different course
    if (video.courseId != null &&
        selectedCourseId != null &&
        video.courseId != selectedCourseId) {
      // Video is from a different course - navigate to course details page
      _navigateToCourseDetails(video.courseId!);
      return;
    }

    // Check if video is premium and user doesn't have premium access
    // Use singleton service - SINGLE SOURCE OF TRUTH
    final hasPremiumAccess = PremiumService().isPremium;

    if (video.isPremium && !hasPremiumAccess) {
      // Navigate to premium unlock screen
      Navigator.of(context).pushNamed('/premium');
    } else {
      // Navigate to video player
      Navigator.of(context).pushNamed(
        '/video-player',
        arguments: {
          'video': video,
          'sections': courseSections,
        },
      );
    }
  }

  void _navigateToCourseDetails(String courseId) async {
    // Load all courses to find the specific course
    final coursesBloc = context.read<CoursesBloc>();
    final currentState = coursesBloc.state;

    // Get courses list
    List<dynamic>? courses;
    if (currentState is CoursesLoaded) {
      courses = currentState.courses;
    } else {
      // Load courses if not already loaded
      coursesBloc.add(const LoadCourses());
      // Wait for courses to load
      await for (final state in coursesBloc.stream) {
        if (state is CoursesLoaded) {
          courses = state.courses;
          break;
        } else if (state is CoursesError) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load course details'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
      }
    }

    // Find the course
    if (courses != null) {
      try {
        final course = courses.firstWhere((c) => c.id == courseId);

        // Get selected course ID
        String? selectedCourseId;
        if (currentState is CoursesLoaded && currentState.selectedCourse != null) {
          selectedCourseId = currentState.selectedCourse!.id;
        }

        final isSelected = course.id == selectedCourseId;

        // Navigate to course detail page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: coursesBloc,
              child: CourseDetailPage(
                course: course,
                isSelected: isSelected,
              ),
            ),
          ),
        );
      } catch (e) {
        // Course not found - show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Course not found'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}