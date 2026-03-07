import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/thumbnail_cache_service.dart';
import '../../core/utils/localization_helper.dart';
import '../../domain/entities/video.dart';

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
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              _buildThumbnail(theme, isLocked),
              // Title
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    video.getLocalizedTitle(langCode),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildThumbnail(ThemeData theme, bool isLocked) {
    return Container(
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail image or placeholder
          _buildThumbnailImage(theme, isLocked),

          // Play button overlay
          if (!isLocked && !_thumbnailLoading && !_thumbnailError &&
              (_thumbnailData != null || (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)))
            Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 22,
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
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
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
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isLocked
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              )
            : Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isLocked
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                      : theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 22,
                  color: isLocked
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.primary,
                ),
              ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
