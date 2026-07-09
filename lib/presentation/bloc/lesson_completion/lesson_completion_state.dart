import 'package:equatable/equatable.dart';
import '../../../domain/entities/lesson_completion.dart';

abstract class LessonCompletionState extends Equatable {
  const LessonCompletionState();

  @override
  List<Object?> get props => [];
}

class LessonCompletionInitial extends LessonCompletionState {
  const LessonCompletionInitial();
}

class LessonCompletionLoading extends LessonCompletionState {
  const LessonCompletionLoading();
}

class LessonCompletionLoaded extends LessonCompletionState {
  final List<LessonCompletion> completions;
  final Set<String> completedLessonIds;

  LessonCompletionLoaded({
    required this.completions,
    Set<String>? completedLessonIds,
  }) : completedLessonIds = completedLessonIds ??
         completions.map((c) => c.lessonId).toSet();

  bool isLessonCompleted(String lessonId) => completedLessonIds.contains(lessonId);

  int? getScorePercentage(String lessonId) {
    final completion = completions.where((c) => c.lessonId == lessonId).firstOrNull;
    return completion?.scorePercentage;
  }

  int get completedCount => completions.length;

  @override
  List<Object?> get props => [completions, completedLessonIds];

  LessonCompletionLoaded copyWith({
    List<LessonCompletion>? completions,
    Set<String>? completedLessonIds,
  }) {
    return LessonCompletionLoaded(
      completions: completions ?? this.completions,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }
}

class LessonCompletionError extends LessonCompletionState {
  final String message;

  const LessonCompletionError(this.message);

  @override
  List<Object> get props => [message];
}
