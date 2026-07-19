import 'package:flutter/material.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/video.dart';
import '../../core/utils/localization_helper.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/lesson_completion/lesson_completion_state.dart';

/// A dialog shown when all lessons in a section are completed.
///
/// Features:
/// - Congratulatory message with section title
/// - Celebratory icon
/// - "Continue" button to dismiss
class SectionCompletionDialog extends StatelessWidget {
  final Section completedSection;

  const SectionCompletionDialog({
    super.key,
    required this.completedSection,
  });

  /// Check if section is completed after marking the current lesson.
  ///
  /// This considers the current lesson as completed even if the state
  /// hasn't been updated yet (since we just marked it complete).
  static bool isSectionCompleted({
    required Section section,
    required Video currentLesson,
    required LessonCompletionLoaded completionState,
  }) {
    // Check all lessons in the section
    for (final lesson in section.lessons) {
      // Current lesson is being completed, so treat it as completed
      if (lesson.id == currentLesson.id) {
        continue;
      }
      // Check if other lessons are completed
      if (!completionState.isLessonCompleted(lesson.id)) {
        return false;
      }
    }
    return section.lessons.isNotEmpty;
  }

  /// Show the section completion dialog.
  static Future<void> show({
    required BuildContext context,
    required Section completedSection,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SectionCompletionDialog(
        completedSection: completedSection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    final sectionTitle = completedSection.getLocalizedTitle(langCode);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star icon with celebration
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade400,
                    Colors.blue.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              l10n?.sectionCompleted ?? 'Section Completed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Section name
            Text(
              sectionTitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Celebration text
            Text(
              l10n?.sectionCompletedMessage ??
                  "Great job! You've completed all lessons in this section.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n?.continueText ?? 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
