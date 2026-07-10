import 'package:equatable/equatable.dart';

abstract class LessonCompletionEvent extends Equatable {
  const LessonCompletionEvent();

  @override
  List<Object?> get props => [];
}

class LoadCompletions extends LessonCompletionEvent {
  const LoadCompletions();
}

class MarkLessonCompleted extends LessonCompletionEvent {
  final String lessonId;
  final String? courseId;
  final int? scorePercentage;
  final String? lessonType;
  final int? durationSeconds;

  const MarkLessonCompleted(
    this.lessonId, {
    this.courseId,
    this.scorePercentage,
    this.lessonType,
    this.durationSeconds,
  });

  @override
  List<Object?> get props => [lessonId, courseId, scorePercentage, lessonType, durationSeconds];
}

class RemoveLessonCompletion extends LessonCompletionEvent {
  final String lessonId;

  const RemoveLessonCompletion(this.lessonId);

  @override
  List<Object> get props => [lessonId];
}

class ClearAllCompletions extends LessonCompletionEvent {
  const ClearAllCompletions();
}
