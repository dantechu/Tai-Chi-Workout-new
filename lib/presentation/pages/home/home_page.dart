import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/premium_service.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/entities/section.dart';
import '../../../domain/entities/video.dart';
import '../lessons/lesson_router.dart';
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
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting with subtle styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getTimeBasedGreeting(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Course name
                    Text(
                      courseName.isNotEmpty ? courseName : 'Excel Training',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.grid_on_rounded,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                size: 32,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      height: 46,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : theme.colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.searchVideos ?? 'Search videos...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _performSearch();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
          _debounceTimer?.cancel();

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
                          // Video list
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final video = videoState.filteredVideos[index];
                                  return VideoCard(
                                    video: video,
                                    isPremiumUser: isPremium,
                                    onTap: () => _navigateToLesson(video, sections: sections),
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header - clean, flat design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bookmark_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Continue Watching',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Horizontal scrolling bookmark cards
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: bookmarkedVideos.length,
              itemBuilder: (context, index) {
                final video = bookmarkedVideos[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == bookmarkedVideos.length - 1 ? 0 : 12,
                  ),
                  child: BookmarkCard(
                    video: video,
                    isPremiumUser: isPremium,
                    onTap: () => _navigateToLesson(video, sections: sections),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLesson(Video lesson, {List<Section>? sections}) {
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

    // Check if the lesson belongs to a different course
    if (lesson.courseId != null &&
        selectedCourseId != null &&
        lesson.courseId != selectedCourseId) {
      // Lesson is from a different course - navigate to course details page
      _navigateToCourseDetails(lesson.courseId!);
      return;
    }

    // Check if lesson is premium and user doesn't have premium access
    // Use singleton service - SINGLE SOURCE OF TRUTH
    final hasPremiumAccess = PremiumService().isPremium;

    if (lesson.isPremium && !hasPremiumAccess) {
      // Navigate to premium unlock screen
      Navigator.of(context).pushNamed('/premium');
    } else {
      // Check if lesson can be played
      if (!LessonRouter.canPlayLesson(lesson)) {
        final reason = LessonRouter.getCannotPlayReason(lesson);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reason ?? 'Cannot play this lesson'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Navigate to appropriate lesson page based on type
      LessonRouter.navigateToLesson(
        context,
        lesson,
        sections: courseSections,
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