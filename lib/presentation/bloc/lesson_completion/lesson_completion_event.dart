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
  final int? scorePercentage;

  const MarkLessonCompleted(this.lessonId, {this.scorePercentage});

  @override
  List<Object?> get props => [lessonId, scorePercentage];
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
