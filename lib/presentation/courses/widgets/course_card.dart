import 'package:flutter/material.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isSelected;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    final localizedDescription = course.getLocalizedDescription(langCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, theme, colorScheme),
                if (localizedDescription.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildDescription(context, theme),
                ],
                const SizedBox(height: 12),
                _buildStats(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            course.getLocalizedName(langCode),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isSelected ? colorScheme.primary : null,
            ),
          ),
        ),
        if (isSelected) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)?.selected ?? 'Selected',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(BuildContext context, ThemeData theme) {
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    return Text(
      course.getLocalizedDescription(langCode),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        fontSize: 13,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats(BuildContext context, ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildStatChip(
          context,
          icon: Icons.video_library_outlined,
          label: '${course.metadata.totalVideos} ${AppLocalizations.of(context)?.videos ?? 'Videos'}',
        ),
        _buildStatChip(
          context,
          icon: Icons.view_module_outlined,
          label: '${course.metadata.totalSections} ${AppLocalizations.of(context)?.sections ?? 'Sections'}',
        ),
        _buildStatChip(
          context,
          icon: Icons.access_time_outlined,
          label: course.metadata.formattedDuration,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

}
