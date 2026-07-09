import 'package:equatable/equatable.dart';
import '../../../domain/entities/lesson_type.dart';

/// Base class for all lesson-related events
abstract class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object?> get props => [];
}

/// Load lessons for a specific course
class LoadLessons extends LessonEvent {
  final String courseId;
  final int? sectionNumber;

  const LoadLessons({
    required this.courseId,
    this.sectionNumber,
  });

  @override
  List<Object?> get props => [courseId, sectionNumber];
}

/// Filter lessons by type
class FilterLessonsByType extends LessonEvent {
  final LessonType? type;

  const FilterLessonsByType(this.type);

  @override
  List<Object?> get props => [type];
}

/// Mark a lesson as completed
class MarkLessonCompleted extends LessonEvent {
  final String lessonId;

  const MarkLessonCompleted(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

/// Mark a lesson as incomplete
class MarkLessonIncomplete extends LessonEvent {
  final String lessonId;

  const MarkLessonIncomplete(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

/// Clear all filters
class ClearLessonFilters extends LessonEvent {
  const ClearLessonFilters();
}

/// Refresh lessons
class RefreshLessons extends LessonEvent {
  const RefreshLessons();
}
