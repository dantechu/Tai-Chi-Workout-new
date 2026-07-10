import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/lesson_completion_local_datasource.dart';
import 'lesson_completion_event.dart';
import 'lesson_completion_state.dart';

class LessonCompletionBloc extends Bloc<LessonCompletionEvent, LessonCompletionState> {
  final LessonCompletionLocalDataSource localDataSource;

  LessonCompletionBloc({
    required this.localDataSource,
  }) : super(const LessonCompletionInitial()) {
    on<LoadCompletions>(_onLoadCompletions);
    on<MarkLessonCompleted>(_onMarkLessonCompleted);
    on<RemoveLessonCompletion>(_onRemoveLessonCompletion);
    on<ClearAllCompletions>(_onClearAllCompletions);
  }

  Future<void> _onLoadCompletions(
    LoadCompletions event,
    Emitter<LessonCompletionState> emit,
  ) async {
    emit(const LessonCompletionLoading());

    try {
      final completions = await localDataSource.getAllCompletions();
      emit(LessonCompletionLoaded(
        completions: completions.map((m) => m.toEntity()).toList(),
      ));
    } catch (e) {
      emit(LessonCompletionError(e.toString()));
    }
  }

  Future<void> _onMarkLessonCompleted(
    MarkLessonCompleted event,
    Emitter<LessonCompletionState> emit,
  ) async {
    try {
      await localDataSource.markCompleted(
        event.lessonId,
        courseId: event.courseId,
        scorePercentage: event.scorePercentage,
        lessonType: event.lessonType,
        durationSeconds: event.durationSeconds,
      );
      add(const LoadCompletions());
    } catch (e) {
      emit(LessonCompletionError(e.toString()));
    }
  }

  Future<void> _onRemoveLessonCompletion(
    RemoveLessonCompletion event,
    Emitter<LessonCompletionState> emit,
  ) async {
    try {
      await localDataSource.removeCompletion(event.lessonId);
      add(const LoadCompletions());
    } catch (e) {
      emit(LessonCompletionError(e.toString()));
    }
  }

  Future<void> _onClearAllCompletions(
    ClearAllCompletions event,
    Emitter<LessonCompletionState> emit,
  ) async {
    try {
      await localDataSource.clearAllCompletions();
      emit(LessonCompletionLoaded(completions: []));
    } catch (e) {
      emit(LessonCompletionError(e.toString()));
    }
  }
}
