import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/lesson_type.dart';
import '../../core/utils/localization_helper.dart';

/// A list tile widget for displaying lessons of any type.
///
/// Automatically displays the appropriate icon and subtitle based on lesson type.
class LessonListTile extends StatelessWidget {
  final Video lesson;
  final VoidCallback? onTap;
  final bool showPremiumBadge;
  final bool isCompleted;
  final String? languageCode;

  const LessonListTile({
    super.key,
    required this.lesson,
    this.onTap,
    this.showPremiumBadge = true,
    this.isCompleted = false,
    this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final langCode =
        languageCode ?? LocalizationHelper.getCurrentLanguageCode(context);
    final title = lesson.getLocalizedTitle(langCode);
    final subtitle = lesson.getSubtitle();
    final icon = _getIconForType(lesson.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail or type icon
              _buildLeadingWidget(context),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Subtitle with type indicator
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 14,
                          color: _getColorForType(context, lesson.type),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.type.displayName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getColorForType(context, lesson.type),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing indicators
              _buildTrailingWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingWidget(BuildContext context) {
    // Show thumbnail for video/audio/text if available
    if (lesson.thumbnailUrl != null &&
        lesson.thumbnailUrl!.isNotEmpty &&
        (lesson.isVideo || lesson.isAudio || lesson.isText)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 64,
          height: 64,
          child: CachedNetworkImage(
            imageUrl: lesson.thumbnailUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildIconContainer(context),
            errorWidget: (context, url, error) => _buildIconContainer(context),
          ),
        ),
      );
    }

    return _buildIconContainer(context);
  }

  Widget _buildIconContainer(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _getColorForType(context, lesson.type).withValues(alpha: 0.1),
      ),
      child: Icon(
        _getIconForType(lesson.type),
        size: 28,
        color: _getColorForType(context, lesson.type),
      ),
    );
  }

  Widget _buildTrailingWidget(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Completed indicator
        if (isCompleted)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
          ),

        // Premium badge
        if (showPremiumBadge && lesson.isPremium) ...[
          if (isCompleted) const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: 14,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  IconData _getIconForType(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle_outline;
      case LessonType.audio:
        return Icons.headphones;
      case LessonType.text:
        return Icons.article_outlined;
      case LessonType.quiz:
        return Icons.quiz_outlined;
      case LessonType.flashcard:
        return Icons.style_outlined;
    }
  }

  Color _getColorForType(BuildContext context, LessonType type) {
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
}

/// A compact chip-style widget for displaying lesson type
class LessonTypeChip extends StatelessWidget {
  final LessonType type;
  final bool selected;
  final VoidCallback? onTap;

  const LessonTypeChip({
    super.key,
    required this.type,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(type);

    return Material(
      color: selected ? color : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconForType(type),
                size: 16,
                color: selected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                type.displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle_outline;
      case LessonType.audio:
        return Icons.headphones;
      case LessonType.text:
        return Icons.article_outlined;
      case LessonType.quiz:
        return Icons.quiz_outlined;
      case LessonType.flashcard:
        return Icons.style_outlined;
    }
  }

  Color _getColorForType(LessonType type) {
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
}
