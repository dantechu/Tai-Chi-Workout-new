import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/interstitial_ad_service.dart';
import '../courses/bloc/courses_bloc.dart';
import '../courses/bloc/courses_state.dart';
import '../../core/services/next_lesson_service.dart';
import '../../core/utils/localization_helper.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/course.dart';
import '../../l10n/app_localizations.dart';
import '../pages/lessons/lesson_router.dart';

/// A dialog shown when a lesson is completed (text, video, audio).
///
/// Features:
/// - Congratulatory message with lesson title
/// - "Next Lesson" button - shows interstitial ad (if applicable) then navigates
/// - "Close" button - dismisses dialog
/// - Automatically detects if this is the last lesson and shows course complete variant
class LessonCompletionDialog extends StatelessWidget {
  final Video completedLesson;
  final Course? course;
  final List<Section>? sections;

  const LessonCompletionDialog({
    super.key,
    required this.completedLesson,
    this.course,
    this.sections,
  });

  /// Show the lesson completion dialog.
  ///
  /// Returns true if user chose to navigate to next lesson, false otherwise.
  static Future<bool> show({
    required BuildContext context,
    required Video completedLesson,
    Course? course,
    List<Section>? sections,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LessonCompletionDialog(
        completedLesson: completedLesson,
        course: course,
        sections: sections,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);

    // Use sections directly if available, otherwise try to get from course/CoursesBloc
    List<Section>? availableSections = sections;
    Course? currentCourse = course;

    // If no sections passed, try to get from course
    if (availableSections == null || availableSections.isEmpty) {
      availableSections = course?.sections;
    }

    // If still no sections, try CoursesBloc as last resort
    if (availableSections == null || availableSections.isEmpty) {
      try {
        final coursesState = context.read<CoursesBloc>().state;
        if (coursesState is CoursesLoaded) {
          if (completedLesson.courseId != null) {
            currentCourse = coursesState.courses.where(
              (c) => c.id == completedLesson.courseId,
            ).firstOrNull;
          }
          currentCourse ??= coursesState.selectedCourse;
          availableSections = currentCourse?.sections;
        } else if (coursesState is SelectedCourseLoaded) {
          currentCourse = coursesState.course;
          availableSections = coursesState.course.sections;
        } else if (coursesState is CourseSelected) {
          currentCourse = coursesState.course;
          availableSections = coursesState.course.sections;
        }
      } catch (_) {}
    }

    // Find next lesson using sections directly
    NextLessonResult? nextLessonResult;
    if (availableSections != null && availableSections.isNotEmpty) {
      nextLessonResult = NextLessonService.findNextLessonFromSections(
        currentLesson: completedLesson,
        sections: availableSections,
      );
    }

    final hasNextLesson = nextLessonResult?.hasNextLesson ?? false;
    final isCourseComplete = nextLessonResult?.isCourseComplete ?? false;

    // If course is complete, show the course complete dialog
    if (isCourseComplete && currentCourse != null) {
      return _buildCourseCompleteDialog(context, l10n, theme, langCode, currentCourse);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              l10n?.lessonCompleted ?? 'Lesson Completed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Lesson title
            Text(
              completedLesson.getLocalizedTitle(langCode),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Motivational text
            Text(
              l10n?.amazingProgress ?? 'Amazing progress! Keep learning!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            if (hasNextLesson) ...[
              // Next Lesson button (primary)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _onNextLessonPressed(
                    context,
                    nextLessonResult!.nextLesson!,
                    nextLessonResult.nextLessonSection,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    l10n?.nextLesson ?? 'Next Lesson',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Close button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n?.close ?? 'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCompleteDialog(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
    String langCode,
    Course currentCourse,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade400,
                    Colors.orange.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              l10n?.courseCompleted ?? 'Course Completed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Course name
            Text(
              currentCourse.getLocalizedName(langCode),
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
              l10n?.celebrateCourseComplete ??
                  "You've mastered this course. Celebrate your achievement!",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Back to Home button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Pop dialog and go back to home
                  Navigator.of(context).pop(false);
                  // Pop current lesson page
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.home_rounded),
                label: Text(
                  l10n?.backToHome ?? 'Back to Home',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNextLessonPressed(
    BuildContext context,
    Video nextLesson,
    Section? nextSection,
  ) {
    // Capture navigator before closing dialog (context becomes invalid after pop)
    final navigator = Navigator.of(context);

    // Get all sections for navigation
    final allSections = sections ?? course?.sections;

    // Close the dialog
    navigator.pop(true);

    // Show interstitial ad if applicable, then navigate
    InterstitialAdService().showAdIfReady(
      onAdDismissed: () {
        // Use pushReplacement to replace current lesson page with next lesson
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => LessonRouter.buildLessonPage(
              nextLesson,
              sections: allSections,
            ),
          ),
        );
      },
    );
  }
}
