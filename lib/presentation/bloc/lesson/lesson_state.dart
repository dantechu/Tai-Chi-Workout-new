import 'package:equatable/equatable.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/entities/lesson_type.dart';

/// Base class for all lesson-related states
abstract class LessonState extends Equatable {
  const LessonState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any lessons are loaded
class LessonInitial extends LessonState {
  const LessonInitial();
}

/// Loading state while fetching lessons
class LessonLoading extends LessonState {
  const LessonLoading();
}

/// State when lessons are successfully loaded
class LessonLoaded extends LessonState {
  final List<Video> allLessons;
  final List<Video> filteredLessons;
  final LessonType? filterType;
  final Set<String> completedLessonIds;

  const LessonLoaded({
    required this.allLessons,
    required this.filteredLessons,
    this.filterType,
    this.completedLessonIds = const {},
  });

  /// Get lessons grouped by section
  Map<int, List<Video>> get lessonsBySection {
    final map = <int, List<Video>>{};
    for (final lesson in filteredLessons) {
      final section = lesson.sectionNumber;
      map[section] ??= [];
      map[section]!.add(lesson);
    }
    return map;
  }

  /// Get count of lessons by type
  Map<LessonType, int> get lessonCountByType {
    final map = <LessonType, int>{};
    for (final lesson in allLessons) {
      map[lesson.type] = (map[lesson.type] ?? 0) + 1;
    }
    return map;
  }

  /// Check if a lesson is completed
  bool isLessonCompleted(String lessonId) {
    return completedLessonIds.contains(lessonId);
  }

  /// Get total duration of all lessons
  Duration get totalDuration {
    return allLessons.fold(
      Duration.zero,
      (total, lesson) => total + lesson.estimatedDuration,
    );
  }

  /// Get total duration of filtered lessons
  Duration get filteredDuration {
    return filteredLessons.fold(
      Duration.zero,
      (total, lesson) => total + lesson.estimatedDuration,
    );
  }

  /// Get count of completed lessons
  int get completedCount {
    return allLessons.where((l) => completedLessonIds.contains(l.id)).length;
  }

  /// Get completion percentage
  double get completionPercentage {
    if (allLessons.isEmpty) return 0;
    return (completedCount / allLessons.length) * 100;
  }

  LessonLoaded copyWith({
    List<Video>? allLessons,
    List<Video>? filteredLessons,
    LessonType? filterType,
    Set<String>? completedLessonIds,
    bool clearFilter = false,
  }) {
    return LessonLoaded(
      allLessons: allLessons ?? this.allLessons,
      filteredLessons: filteredLessons ?? this.filteredLessons,
      filterType: clearFilter ? null : (filterType ?? this.filterType),
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }

  @override
  List<Object?> get props => [
        allLessons,
        filteredLessons,
        filterType,
        completedLessonIds,
      ];
}

/// Error state when loading lessons fails
class LessonError extends LessonState {
  final String message;

  const LessonError(this.message);

  @override
  List<Object?> get props => [message];
}
