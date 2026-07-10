import 'dart:ui';
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
    final isDark = theme.brightness == Brightness.dark;
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    final localizedDescription = course.getLocalizedDescription(langCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.08)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.4)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : colorScheme.outline.withValues(alpha: 0.08),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, theme, colorScheme),
                      if (localizedDescription.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDescription(context, theme),
                      ],
                      const SizedBox(height: 14),
                      _buildStats(context, theme),
                    ],
                  ),
                ),
              ),
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.15)
                : colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.school_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            course.getLocalizedName(langCode),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isSelected ? colorScheme.primary : null,
            ),
          ),
        ),
        if (isSelected) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.of(context)?.selected ?? 'Selected',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(BuildContext context, ThemeData theme) {
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    return Padding(
      padding: const EdgeInsets.only(left: 54), // Align with title after icon
      child: Text(
        course.getLocalizedDescription(langCode),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 13,
          height: 1.5,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStats(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.04 : 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip(
            context,
            icon: Icons.play_circle_outline_rounded,
            label: '${course.totalVideos}',
            sublabel: AppLocalizations.of(context)?.lessons ?? 'Lessons',
          ),
          Container(
            width: 1,
            height: 28,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          _buildStatChip(
            context,
            icon: Icons.layers_outlined,
            label: '${course.metadata.totalSections}',
            sublabel: AppLocalizations.of(context)?.sections ?? 'Sections',
          ),
          Container(
            width: 1,
            height: 28,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          _buildStatChip(
            context,
            icon: Icons.schedule_rounded,
            label: course.metadata.formattedDuration,
            sublabel: '',
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sublabel,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            if (sublabel.isNotEmpty)
              Text(
                sublabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
