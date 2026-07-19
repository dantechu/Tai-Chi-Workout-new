import 'package:flutter/material.dart';
import '../../core/services/certificate_service.dart';
import '../../core/utils/localization_helper.dart';
import '../../domain/entities/course.dart';
import '../../l10n/app_localizations.dart';
import '../pages/certificate/certificate_name_page.dart';
import '../pages/certificate/certificate_view_page.dart';

/// A dialog shown when a course is completed.
///
/// Features:
/// - Congratulatory message with trophy icon
/// - If course has certificate: "Get Certificate" and "Close" buttons
/// - If no certificate: "Close" button only
/// - Handles certificate name flow (name entry or direct view)
class CourseCompletionDialog extends StatelessWidget {
  final Course course;

  const CourseCompletionDialog({
    super.key,
    required this.course,
  });

  /// Show the course completion dialog.
  ///
  /// Returns true if user clicked "Get Certificate", false otherwise.
  static Future<bool> show({
    required BuildContext context,
    required Course course,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CourseCompletionDialog(course: course),
    );
    return result ?? false;
  }

  /// Check if all lessons in a course are completed.
  static bool isCourseCompleted({
    required Course course,
    required dynamic completionState,
    String? currentLessonId,
  }) {
    // Get all lessons from all sections
    for (final section in course.sections) {
      for (final lesson in section.lessons) {
        // Current lesson is being completed, so treat it as completed
        if (lesson.id == currentLessonId) {
          continue;
        }
        // Check if other lessons are completed
        if (!completionState.isLessonCompleted(lesson.id)) {
          return false;
        }
      }
    }
    // All lessons must be completed (including at least one lesson)
    return course.sections.isNotEmpty &&
        course.sections.any((s) => s.lessons.isNotEmpty);
  }

  void _onGetCertificate(BuildContext context) async {
    Navigator.of(context).pop(true); // Return true to indicate certificate flow

    final certificateService = CertificateService();

    // Check if name already exists
    final hasName = await certificateService.hasEnteredName();

    if (!context.mounted) return;

    if (hasName) {
      // Name already entered, go directly to certificate view
      final name = await certificateService.getCertificateName();
      if (name != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificateViewPage(
              course: course,
              userName: name,
            ),
          ),
        );
      }
    } else {
      // Need to enter name first
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CertificateNamePage(course: course),
        ),
      );
    }
  }

  void _onClose(BuildContext context) {
    Navigator.of(context).pop(false);
    // Navigate back to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langCode = LocalizationHelper.getCurrentLanguageCode(context);
    final courseName = course.getLocalizedName(langCode);
    final hasCertificate = course.hasCertificate;

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
              courseName,
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
                  "Congratulations! You've completed this entire course.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            // Certificate message if available
            if (hasCertificate) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.certificateAvailable ?? 'Certificate available!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Buttons
            if (hasCertificate) ...[
              // Get Certificate button (primary)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _onGetCertificate(context),
                  icon: const Icon(Icons.verified_rounded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: Text(
                    l10n?.getCertificate ?? 'Get Certificate',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Close button (secondary)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => _onClose(context),
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
            ] else ...[
              // Close button (primary when no certificate)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _onClose(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n?.backToHome ?? 'Back to Home',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
