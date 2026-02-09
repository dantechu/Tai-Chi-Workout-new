import 'package:flutter/material.dart';
import '../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final bool isPremiumUser;
  final VoidCallback onTap;

  const VideoCard({
    super.key,
    required this.video,
    required this.isPremiumUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = video.isPremium && !isPremiumUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
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
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Video thumbnail placeholder
          Center(
            child: Icon(
              Icons.play_circle_filled,
              size: 48,
              color: isLocked 
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          
          // Duration badge
          if (video.duration.inSeconds > 0)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(video.duration.inSeconds),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          // Premium lock overlay
          if (isLocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.lock,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isLocked) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      video.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (video.isPremium)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PRO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                video.category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          
          // Action button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isLocked)
                Text(
                  'Premium Required',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                Icon(
                  Icons.play_arrow,
                  color: theme.colorScheme.primary,
                  size: 24,
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