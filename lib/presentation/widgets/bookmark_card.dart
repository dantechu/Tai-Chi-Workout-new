import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/thumbnail_cache_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/localization_helper.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/lesson_type.dart';
import '../../l10n/app_localizations.dart';

class BookmarkCard extends StatefulWidget {
  final Video video;
  final bool isPremiumUser;
  final VoidCallback onTap;

  const BookmarkCard({
    super.key,
    required this.video,
    required this.isPremiumUser,
    required this.onTap,
  });

  @override
  State<BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<BookmarkCard> {
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
  void didUpdateWidget(BookmarkCard oldWidget) {
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
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);

    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppColors.radiusMD),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppColors.radiusMD),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppColors.radiusMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with 16:9 aspect ratio
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppColors.radiusMD),
                    topRight: Radius.circular(AppColors.radiusMD),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildThumbnailImage(theme, isLocked),

                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Action button based on lesson type
                        if (!isLocked && !_thumbnailLoading && !_thumbnailError &&
                            (_thumbnailData != null || (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)))
                          Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getLessonTypeColor(video.type).withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getLessonTypeIcon(video.type),
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        // Duration/Info badge
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(AppColors.radiusXS),
                            ),
                            child: Text(
                              _getLessonSubtitle(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // PRO badge
                        if (video.isPremium)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(AppColors.radiusXS),
                              ),
                              child: Text(
                                AppLocalizations.of(context)?.pro ?? 'PRO',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                        // Lock overlay
                        if (isLocked)
                          Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Title
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      video.getLocalizedTitle(langCode),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.3,
                        color: isLocked
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(ThemeData theme, bool isLocked) {
    if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: video.thumbnailUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(theme, isLocked, isLoading: true),
        errorWidget: (context, url, error) => _buildPlaceholder(theme, isLocked),
      );
    }

    if (_thumbnailData != null) {
      return Image.memory(
        _thumbnailData!,
        fit: BoxFit.cover,
      );
    }

    if (_thumbnailLoading) {
      return _buildPlaceholder(theme, isLocked, isLoading: true);
    }

    return _buildPlaceholder(theme, isLocked);
  }

  Widget _buildPlaceholder(ThemeData theme, bool isLocked, {bool isLoading = false}) {
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _getLessonTypeColor(video.type);

    return Container(
      color: isDark
          ? typeColor.withValues(alpha: 0.15)
          : typeColor.withValues(alpha: 0.1),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: typeColor.withValues(alpha: 0.6),
                ),
              )
            : Icon(
                _getLessonTypeIcon(video.type),
                size: 36,
                color: isLocked
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                    : typeColor.withValues(alpha: 0.7),
              ),
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
    final l10n = AppLocalizations.of(context);
    switch (video.type) {
      case LessonType.video:
      case LessonType.audio:
        return _formatDuration(video.duration.inSeconds);
      case LessonType.text:
        final minutes = (video.estimatedReadTime ?? video.duration.inSeconds) ~/ 60;
        return '$minutes ${l10n?.minRead ?? 'min read'}';
      case LessonType.quiz:
        final count = video.questions?.length ?? 0;
        return l10n?.nQuestions(count) ?? '$count questions';
      case LessonType.flashcard:
        final count = video.cards?.length ?? 0;
        return l10n?.nCards(count) ?? '$count cards';
    }
  }
}
