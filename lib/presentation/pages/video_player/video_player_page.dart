import 'dart:io';
import '../../../core/services/premium_service.dart';
import '../../../core/services/ad_unlock_service.dart';
import '../../../core/network/network_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/localization_helper.dart';
import '../../../domain/entities/section.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/usecases/download_usecases.dart';
import '../../../injection_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/bookmark/bookmark_bloc.dart';
import '../../bloc/bookmark/bookmark_event.dart';
import '../../bloc/bookmark/bookmark_state.dart';
import '../../bloc/lesson_completion/lesson_completion_bloc.dart';
import '../../bloc/lesson_completion/lesson_completion_event.dart';
import '../../bloc/premium/premium_bloc.dart';
import '../../bloc/premium/premium_state.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_state.dart' show CoursesLoaded, SelectedCourseLoaded, CourseSelected;
import '../../widgets/banner_ad_widget.dart';
import '../../../core/services/certificate_service.dart';
import '../../widgets/lesson_completion_dialog.dart';
import '../../widgets/section_completion_dialog.dart';
import '../../widgets/course_completion_dialog.dart';
import '../../bloc/lesson_completion/lesson_completion_state.dart';

class VideoPlayerPage extends StatefulWidget {
  final Video video;
  final List<Section>? sections;

  const VideoPlayerPage({
    super.key,
    required this.video,
    this.sections,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;
  bool _hasMarkedComplete = false;
  bool _hasShownCompletionDialog = false;
  bool _isPlayingOffline = false;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Check if user has premium access for premium videos
      if (!mounted) return;
      // Use singleton service - SINGLE SOURCE OF TRUTH
      final hasPremiumAccess = PremiumService().isPremium;
      final isAdUnlocked = AdUnlockService().isLessonUnlocked(widget.video.id);

      if (widget.video.isPremium && !hasPremiumAccess && !isAdUnlocked) {
        setState(() {
          // Use default message - will be localized in build()
          _error = 'Premium subscription required to watch this video';
          _isLoading = false;
        });
        return;
      }

      // Check if video is downloaded locally
      final getLocalVideoPath = sl<GetLocalVideoPath>();
      final localPathResult = await getLocalVideoPath(widget.video.id);
      String? localPath;
      localPathResult.fold(
        (failure) => localPath = null,
        (path) => localPath = path,
      );

      // Check network connectivity
      final networkInfo = sl<NetworkInfo>();
      final hasInternet = await networkInfo.isConnected;

      // Determine video source
      if (localPath != null && await File(localPath!).exists()) {
        // Use local file for playback
        _isDownloaded = true;
        _isPlayingOffline = !hasInternet;
        _videoPlayerController = VideoPlayerController.file(
          File(localPath!),
        );
      } else if (hasInternet) {
        _isDownloaded = false;
        // Check if video URL is available
        final videoUrl = widget.video.videoUrl;
        if (videoUrl == null || videoUrl.isEmpty) {
          setState(() {
            _error = 'No video URL available for this lesson';
            _isLoading = false;
          });
          return;
        }

        // Use network URL for playback
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
      } else {
        // Offline and not downloaded
        setState(() {
          _error = 'Video not available offline. Download it first when online.';
          _isLoading = false;
        });
        return;
      }

      await _videoPlayerController.initialize();

      // Add listener for completion tracking
      _videoPlayerController.addListener(_checkVideoProgress);

      // Initialize Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        allowMuting: true,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: mounted ? Theme.of(context).colorScheme.primary : Colors.blue,
          handleColor: mounted ? Theme.of(context).colorScheme.primary : Colors.blue,
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
          bufferedColor: Colors.grey.withValues(alpha: 0.6),
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.videoPlaybackError ?? 'Video playback error',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load video: ${e.toString()}');
      setState(() {
        _error = 'Failed to load video: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _checkVideoProgress() {
    final position = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;

    if (duration.inMilliseconds == 0) return;

    final progress = position.inMilliseconds / duration.inMilliseconds;

    // Mark as complete if progress is 90% or more (background tracking)
    if (!_hasMarkedComplete && progress >= 0.9) {
      _hasMarkedComplete = true;
      context.read<LessonCompletionBloc>().add(
        MarkLessonCompleted(
          widget.video.id,
          courseId: widget.video.courseId,
          lessonType: 'video',
          durationSeconds: widget.video.duration.inSeconds,
        ),
      );
    }

    // Show completion dialog at 100% (or when video ends)
    if (!_hasShownCompletionDialog && progress >= 0.99) {
      _hasShownCompletionDialog = true;
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() async {
    // Get the completion state before showing dialog
    final completionState = context.read<LessonCompletionBloc>().state;

    // Get the current course from CoursesBloc
    Course? currentCourse;
    try {
      final coursesState = context.read<CoursesBloc>().state;
      if (coursesState is CoursesLoaded) {
        // First try selectedCourse, then find by courseId
        currentCourse = coursesState.selectedCourse;
        if (currentCourse == null && widget.video.courseId != null) {
          currentCourse = coursesState.courses.where(
            (c) => c.id == widget.video.courseId,
          ).firstOrNull;
        }
      } else if (coursesState is SelectedCourseLoaded) {
        currentCourse = coursesState.course;
      } else if (coursesState is CourseSelected) {
        currentCourse = coursesState.course;
      }
    } catch (_) {
      // CoursesBloc not available
    }

    // Pause the video before showing dialog
    _videoPlayerController.pause();

    final availableSections = widget.sections ?? currentCourse?.sections;

    // Show the lesson completion dialog
    await LessonCompletionDialog.show(
      context: context,
      completedLesson: widget.video,
      course: currentCourse,
      sections: availableSections,
    );

    // Check for COURSE completion first (takes priority over section completion)
    if (completionState is LessonCompletionLoaded && currentCourse != null) {
      final isCourseComplete = CourseCompletionDialog.isCourseCompleted(
        course: currentCourse,
        completionState: completionState,
        currentLessonId: widget.video.id,
      );

      if (isCourseComplete && mounted) {
        // Mark course as completed for certificate purposes
        await CertificateService().markCourseCompleted(currentCourse.id);

        // Show course completion dialog and skip section dialog
        await CourseCompletionDialog.show(
          context: context,
          course: currentCourse,
        );
        return; // Don't show section dialog
      }
    }

    // Check for section completion after lesson dialog is dismissed
    if (completionState is LessonCompletionLoaded && availableSections != null) {
      // Find the section containing this lesson
      for (final section in availableSections) {
        final lessonInSection = section.lessons.any((l) => l.id == widget.video.id);
        if (lessonInSection) {
          // Check if all lessons in this section are now completed
          final isSectionComplete = SectionCompletionDialog.isSectionCompleted(
            section: section,
            currentLesson: widget.video,
            completionState: completionState,
          );

          if (isSectionComplete && mounted) {
            await SectionCompletionDialog.show(
              context: context,
              completedSection: section,
            );
          }
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_checkVideoProgress);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.video.getLocalizedTitle(langCode),
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Bookmark button
          BlocBuilder<BookmarkBloc, BookmarkState>(
            builder: (context, state) {
              final isBookmarked = state is BookmarkLoaded &&
                  state.isVideoBookmarked(widget.video.id);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? Theme.of(context).colorScheme.primary : Colors.white,
                ),
                onPressed: () {
                  context.read<BookmarkBloc>().add(ToggleBookmark(widget.video.id));
                  final message = isBookmarked
                      ? 'Removed from bookmarks'
                      : 'Added to bookmarks';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          // Offline indicator
          if (_isPlayingOffline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.offline_bolt, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Text('Offline', style: TextStyle(color: Colors.orange, fontSize: 12)),
                ],
              ),
            ),
          if (!widget.video.isPremium ||
              PremiumService().isPremium)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                if (_isDownloaded)
                  PopupMenuItem(
                    value: 'delete_download',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)?.delete ?? 'Delete Download'),
                      ],
                    ),
                  )
                else
                  PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)?.download ?? 'Download'),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Video Player
          Container(
            height: 250,
            color: Colors.black,
            child: _buildVideoPlayer(),
          ),

          // Video Info
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVideoInfo(),
                    const SizedBox(height: 24),
                    _buildVideoDescription(),
                  ],
                ),
              ),
            ),
          ),

          // Banner Ad at bottom (only show if not premium)
          BlocBuilder<PremiumBloc, PremiumState>(
            builder: (context, state) {
              // Use singleton service - SINGLE SOURCE OF TRUTH
              final isPremium = PremiumService().isPremium;
              if (isPremium) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Theme.of(context).colorScheme.surface,
                child: SafeArea(
                  top: false,
                  child: const BannerAdWidget(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.video.isPremium)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/premium');
                  },
                  child: Text(AppLocalizations.of(context)?.getPremium ?? 'Get Premium'),
                )
              else
                ElevatedButton(
                  onPressed: _initializePlayer,
                  child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                ),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return Center(
      child: Text(
        AppLocalizations.of(context)?.videoPlayerNotAvailable ?? 'Video player not available',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  /// Get localized section name from sections list or fall back to category
  String _getLocalizedSectionName(String langCode, List<Section>? sections) {
    if (sections != null) {
      // Try to find section by sectionNumber first
      final section = sections.where(
        (s) => s.sectionNumber == widget.video.sectionNumber
      ).firstOrNull;
      if (section != null) {
        return section.getLocalizedTitle(langCode);
      }
      // Fall back to matching by title
      final sectionByTitle = sections.where(
        (s) => s.title == widget.video.category
      ).firstOrNull;
      if (sectionByTitle != null) {
        return sectionByTitle.getLocalizedTitle(langCode);
      }
    }
    // Fall back to helper
    return LocalizationHelper.getLocalizedCategoryName(context, widget.video.category);
  }

  Widget _buildVideoInfo() {
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.video.getLocalizedTitle(langCode),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.layers_outlined,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _getLocalizedSectionName(langCode, widget.sections),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _formatDuration(widget.video.duration),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoDescription() {
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    final description = widget.video.getLocalizedDescription(langCode) ??
        AppLocalizations.of(context)?.defaultVideoDescription ??
        'Master the art of Tai Chi with this comprehensive lesson.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.description ?? 'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'download':
        _showDownloadDialog();
        break;
      case 'delete_download':
        _showDeleteDownloadDialog();
        break;
    }
  }

  void _showDeleteDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.delete ?? 'Delete Download'),
        content: const Text('Are you sure you want to delete this downloaded video? You will need to download it again to watch offline.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDownload();
            },
            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDownload() async {
    try {
      final getDownloadByVideoId = sl<GetDownloadByVideoId>();
      final result = await getDownloadByVideoId(widget.video.id);

      await result.fold(
        (failure) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to find download: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (downloadItem) async {
          if (downloadItem != null) {
            final deleteDownload = sl<DeleteDownload>();
            final deleteResult = await deleteDownload(downloadItem.id);

            deleteResult.fold(
              (failure) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: ${failure.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              (_) {
                if (mounted) {
                  setState(() {
                    _isDownloaded = false;
                    _isPlayingOffline = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Download deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDownloadDialog() {
    // Check premium status - use singleton service
    final hasPremium = PremiumService().isPremium;

    if (!hasPremium) {
      // Show premium required dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Premium Required'),
          content: const Text('Offline downloads are available for premium users only. Upgrade to premium to download videos for offline viewing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/premium');
              },
              child: Text(AppLocalizations.of(context)?.getPremium ?? 'Get Premium'),
            ),
          ],
        ),
      );
      return;
    }

    // Show download confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.downloadVideo ?? 'Download Video'),
        content: Text(AppLocalizations.of(context)?.downloadVideoConfirmation ?? 'Download this video for offline viewing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startDownload();
            },
            child: Text(AppLocalizations.of(context)?.download ?? 'Download'),
          ),
        ],
      ),
    );
  }

  Future<void> _startDownload() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download started...'),
          duration: Duration(seconds: 2),
        ),
      );

      final downloadVideo = sl<DownloadVideo>();
      final result = await downloadVideo(widget.video);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download failed: ${failure.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        (downloadItem) {
          if (mounted) {
            final langCode = LocalizationHelper.getCurrentLanguageCode(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloading ${widget.video.getLocalizedTitle(langCode)}...'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}