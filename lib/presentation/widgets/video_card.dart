import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/thumbnail_cache_service.dart';
import '../../core/utils/localization_helper.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/video.dart';
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

    // Check cache first
    final cached = _thumbnailCache.getCached(widget.video.videoUrl);
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
    final thumbnail = await _thumbnailCache.getThumbnail(widget.video.videoUrl);

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
    final isLocked = video.isPremium && !isPremiumUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
          child: SizedBox(
            height: 100,
            child: Row(
              children: [
                _buildThumbnail(theme, isLocked),
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
    return Container(
      width: 110,
      height: 100,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail image or placeholder
          _buildThumbnailImage(theme, isLocked),

          // Play button overlay
          if (!isLocked && !_thumbnailLoading && !_thumbnailError && (_thumbnailData != null || (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)))
            Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),

          // Duration badge
          if (video.duration.inSeconds > 0)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(video.duration.inSeconds),
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
                color: Colors.black.withValues(alpha: 0.55),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLocked
              ? [
                  theme.colorScheme.surfaceContainerHighest,
                  theme.colorScheme.surfaceContainerHigh,
                ]
              : [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                ],
        ),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isLocked
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              )
            : Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLocked
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                      : theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 28,
                  color: isLocked
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.primary,
                ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  video.getLocalizedTitle(langCode),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.3,
                    color: isLocked
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                        : theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isLocked) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.tertiary.withValues(alpha: 0.2),
                        theme.colorScheme.tertiary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PRO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Category and action row
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _getLocalizedSectionName(langCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Bookmark button
              BlocBuilder<BookmarkBloc, BookmarkState>(
                builder: (context, state) {
                  final isBookmarked = state is BookmarkLoaded &&
                      state.isVideoBookmarked(video.id);
                  return GestureDetector(
                    onTap: () {
                      context.read<BookmarkBloc>().add(ToggleBookmark(video.id));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isBookmarked
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              Icon(
                isLocked ? Icons.lock_outline_rounded : Icons.arrow_forward_ios_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: isLocked ? 0.3 : 0.35),
                size: isLocked ? 16 : 14,
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
}