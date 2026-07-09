import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/thumbnail_cache_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/localization_helper.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/lesson_type.dart';
import '../bloc/bookmark/bookmark_bloc.dart';
import '../bloc/bookmark/bookmark_event.dart';
import '../bloc/bookmark/bookmark_state.dart';

class VideoCard extends StatefulWidget {
  final Video video;
  final bool isPremiumUser;
  final VoidCallback onTap;
  final List<Section>? sections;

  const VideoCard({
    super.key,
    required this.video,
    required this.isPremiumUser,
    required this.onTap,
    this.sections,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  final ThumbnailCacheService _thumbnailCache = ThumbnailCacheService();
  Uint8List? _thumbnailData;
  bool _thumbnailLoading = true;
  bool _thumbnailError = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.videoUrl != widget.video.videoUrl) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    // If thumbnailUrl is provided, we'll use CachedNetworkImage instead
    if (widget.video.thumbnailUrl != null && widget.video.thumbnailUrl!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _thumbnailLoading = false;
          _thumbnailError = false;
        });
      }
      return;
    }

    // If no videoUrl (e.g., text/quiz/flashcard lessons), show placeholder
    final videoUrl = widget.video.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _thumbnailLoading = false;
          _thumbnailError = false;
        });
      }
      return;
    }

    // Check cache first
    final cached = _thumbnailCache.getCached(videoUrl);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _thumbnailData = cached;
          _thumbnailLoading = false;
          _thumbnailError = false;
        });
      }
      return;
    }

    // Extract thumbnail using cache service
    final thumbnail = await _thumbnailCache.getThumbnail(videoUrl);

    if (mounted) {
      setState(() {
        _thumbnailData = thumbnail;
        _thumbnailLoading = false;
        _thumbnailError = thumbnail == null;
      });
    }
  }

  Video get video => widget.video;
  bool get isPremiumUser => widget.isPremiumUser;
  VoidCallback get onTap => widget.onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLocked = video.isPremium && !isPremiumUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail section - left side
                _buildThumbnail(theme, isLocked),
                const SizedBox(width: 14),
                // Content section - right side
                Expanded(
                  child: _buildContent(theme, isLocked),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ThemeData theme, bool isLocked) {
    return SizedBox(
      width: 130,
      height: 90,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail image or placeholder
            _buildThumbnailImage(theme, isLocked),

            // Action button overlay based on lesson type
            if (!isLocked && !_thumbnailLoading && !_thumbnailError && (_thumbnailData != null || (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)))
              Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getLessonTypeColor(video.type).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getLessonTypeIcon(video.type),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),

            // Duration/Info badge - bottom right
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getLessonSubtitle(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Premium lock overlay
            if (isLocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(ThemeData theme, bool isLocked) {
    // If thumbnailUrl is provided, use CachedNetworkImage
    if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: video.thumbnailUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(theme, isLocked, isLoading: true),
        errorWidget: (context, url, error) => _buildPlaceholder(theme, isLocked),
      );
    }

    // If thumbnail was extracted from video
    if (_thumbnailData != null) {
      return Image.memory(
        _thumbnailData!,
        fit: BoxFit.cover,
      );
    }

    // Loading state
    if (_thumbnailLoading) {
      return _buildPlaceholder(theme, isLocked, isLoading: true);
    }

    // Fallback placeholder
    return _buildPlaceholder(theme, isLocked);
  }

  Widget _buildPlaceholder(ThemeData theme, bool isLocked, {bool isLoading = false}) {
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _getLessonTypeColor(video.type);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? typeColor.withValues(alpha: 0.15)
            : typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: typeColor.withValues(alpha: 0.6),
                ),
              )
            : Icon(
                _getLessonTypeIcon(video.type),
                size: 32,
                color: isLocked
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                    : typeColor.withValues(alpha: 0.7),
              ),
      ),
    );
  }

  /// Get localized section name from sections list or fall back to category
  String _getLocalizedSectionName(String langCode) {
    if (widget.sections != null) {
      // Try to find section by sectionNumber first
      final section = widget.sections!.where(
        (s) => s.sectionNumber == video.sectionNumber
      ).firstOrNull;
      if (section != null) {
        return section.getLocalizedTitle(langCode);
      }
      // Fall back to matching by title
      final sectionByTitle = widget.sections!.where(
        (s) => s.title == video.category
      ).firstOrNull;
      if (sectionByTitle != null) {
        return sectionByTitle.getLocalizedTitle(langCode);
      }
    }
    // Fall back to helper
    return LocalizationHelper.getLocalizedCategoryName(context, video.category);
  }

  Widget _buildContent(ThemeData theme, bool isLocked) {
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: PRO badge if premium
          if (video.isPremium)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PRO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          // Title
          Expanded(
            child: Text(
              video.getLocalizedTitle(langCode),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: isLocked
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                    : theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 6),

          // Bottom row: Category and bookmark
          Row(
            children: [
              // Category/Section name
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 13,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _getLocalizedSectionName(langCode),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Bookmark button
              BlocBuilder<BookmarkBloc, BookmarkState>(
                builder: (context, state) {
                  final isBookmarked = state is BookmarkLoaded &&
                      state.isVideoBookmarked(video.id);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.read<BookmarkBloc>().add(ToggleBookmark(video.id));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isBookmarked
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Get icon for lesson type
  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_arrow_rounded;
      case LessonType.audio:
        return Icons.headphones_rounded;
      case LessonType.text:
        return Icons.article_rounded;
      case LessonType.quiz:
        return Icons.quiz_rounded;
      case LessonType.flashcard:
        return Icons.style_rounded;
    }
  }

  /// Get color for lesson type
  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Colors.blue;
      case LessonType.audio:
        return Colors.purple;
      case LessonType.text:
        return Colors.teal;
      case LessonType.quiz:
        return Colors.orange;
      case LessonType.flashcard:
        return Colors.pink;
    }
  }

  /// Get subtitle text based on lesson type
  String _getLessonSubtitle() {
    switch (video.type) {
      case LessonType.video:
      case LessonType.audio:
        return _formatDuration(video.duration.inSeconds);
      case LessonType.text:
        final minutes = (video.estimatedReadTime ?? video.duration.inSeconds) ~/ 60;
        return '$minutes min read';
      case LessonType.quiz:
        final count = video.questions?.length ?? 0;
        return '$count questions';
      case LessonType.flashcard:
        final count = video.cards?.length ?? 0;
        return '$count cards';
    }
  }
}
