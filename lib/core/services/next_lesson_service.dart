import '../../domain/entities/video.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/course.dart';

/// Result of finding the next lesson
class NextLessonResult {
  final Video? nextLesson;
  final bool isCourseComplete;
  final Section? nextLessonSection;

  const NextLessonResult({
    this.nextLesson,
    this.isCourseComplete = false,
    this.nextLessonSection,
  });

  bool get hasNextLesson => nextLesson != null;
}

/// Service to determine the next lesson in a course.
///
/// Navigation logic:
/// 1. Try to find next lesson in the same section (by rowNumber)
/// 2. If section is complete, move to first lesson of next section (by order)
/// 3. If course is complete, return isCourseComplete = true
class NextLessonService {
  /// Find the next lesson after the current lesson.
  ///
  /// [currentLesson] - The lesson the user just completed
  /// [course] - The full course containing all sections and lessons
  ///
  /// Returns [NextLessonResult] with either:
  /// - nextLesson populated if there's a next lesson
  /// - isCourseComplete = true if this was the last lesson
  static NextLessonResult findNextLesson({
    required Video currentLesson,
    required Course course,
  }) {
    return findNextLessonFromSections(
      currentLesson: currentLesson,
      sections: course.sections,
    );
  }

  /// Find the next lesson using sections directly (no Course object needed).
  static NextLessonResult findNextLessonFromSections({
    required Video currentLesson,
    required List<Section> sections,
  }) {
    if (sections.isEmpty) {
      return const NextLessonResult(isCourseComplete: true);
    }

    // Sort sections by order
    final sortedSections = List<Section>.from(sections)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Find current section
    final currentSectionIndex = sortedSections.indexWhere(
      (s) => s.sectionNumber == currentLesson.sectionNumber,
    );

    if (currentSectionIndex == -1) {
      // Current section not found, course might be complete
      return const NextLessonResult(isCourseComplete: true);
    }

    final currentSection = sortedSections[currentSectionIndex];

    // Sort lessons in current section by rowNumber
    final sortedLessons = List<Video>.from(currentSection.videos)
      ..sort((a, b) => a.rowNumber.compareTo(b.rowNumber));

    // Find current lesson index
    final currentLessonIndex = sortedLessons.indexWhere(
      (v) => v.id == currentLesson.id,
    );

    if (currentLessonIndex == -1) {
      // Current lesson not found in section, try by rowNumber
      final byRowNumber = sortedLessons.indexWhere(
        (v) => v.rowNumber == currentLesson.rowNumber,
      );
      if (byRowNumber == -1) {
        return const NextLessonResult(isCourseComplete: true);
      }
    }

    final lessonIndex = currentLessonIndex != -1
        ? currentLessonIndex
        : sortedLessons.indexWhere(
            (v) => v.rowNumber == currentLesson.rowNumber,
          );

    // Check if there's a next lesson in the same section
    if (lessonIndex < sortedLessons.length - 1) {
      return NextLessonResult(
        nextLesson: sortedLessons[lessonIndex + 1],
        nextLessonSection: currentSection,
      );
    }

    // Current section is complete, try next section
    if (currentSectionIndex < sortedSections.length - 1) {
      final nextSection = sortedSections[currentSectionIndex + 1];

      // Get first lesson of next section
      if (nextSection.videos.isNotEmpty) {
        final nextSectionLessons = List<Video>.from(nextSection.videos)
          ..sort((a, b) => a.rowNumber.compareTo(b.rowNumber));

        return NextLessonResult(
          nextLesson: nextSectionLessons.first,
          nextLessonSection: nextSection,
        );
      }
    }

    // No more lessons - course is complete
    return const NextLessonResult(isCourseComplete: true);
  }

  /// Get all lessons in a course as a flat ordered list.
  static List<Video> getAllLessonsOrdered(Course course) {
    final allLessons = <Video>[];

    // Sort sections by order
    final sortedSections = List<Section>.from(course.sections)
      ..sort((a, b) => a.order.compareTo(b.order));

    for (final section in sortedSections) {
      // Sort lessons by rowNumber within each section
      final sortedLessons = List<Video>.from(section.videos)
        ..sort((a, b) => a.rowNumber.compareTo(b.rowNumber));
      allLessons.addAll(sortedLessons);
    }

    return allLessons;
  }

  /// Get the progress index of a lesson (0-based).
  static int getLessonIndex(Video lesson, Course course) {
    final allLessons = getAllLessonsOrdered(course);
    return allLessons.indexWhere((v) => v.id == lesson.id);
  }

  /// Get total lesson count in a course.
  static int getTotalLessonCount(Course course) {
    return course.sections.fold(0, (sum, s) => sum + s.videos.length);
  }
}
