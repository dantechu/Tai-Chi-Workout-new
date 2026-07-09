import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../domain/entities/video.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

/// BLoC for managing lesson-related state.
///
/// Handles:
/// - Loading lessons from course data
/// - Filtering lessons by type
/// - Tracking lesson completion
class LessonBloc extends Bloc<LessonEvent, LessonState> {
  static const String _completedLessonsBoxName = 'completed_lessons';

  LessonBloc() : super(const LessonInitial()) {
    on<LoadLessons>(_onLoadLessons);
    on<FilterLessonsByType>(_onFilterByType);
    on<MarkLessonCompleted>(_onMarkCompleted);
    on<MarkLessonIncomplete>(_onMarkIncomplete);
    on<ClearLessonFilters>(_onClearFilters);
    on<RefreshLessons>(_onRefresh);
  }

  List<Video> _allLessons = [];

  Future<void> _onLoadLessons(
    LoadLessons event,
    Emitter<LessonState> emit,
  ) async {
    emit(const LessonLoading());

    try {
      // Load completed lesson IDs from local storage
      final completedIds = await _loadCompletedLessonIds(event.courseId);

      // Filter by section if specified
      List<Video> lessons = _allLessons;
      if (event.sectionNumber != null) {
        lessons = lessons
            .where((l) => l.sectionNumber == event.sectionNumber)
            .toList();
      }

      emit(LessonLoaded(
        allLessons: lessons,
        filteredLessons: lessons,
        completedLessonIds: completedIds,
      ));
    } catch (e) {
      emit(LessonError('Failed to load lessons: $e'));
    }
  }

  void _onFilterByType(
    FilterLessonsByType event,
    Emitter<LessonState> emit,
  ) {
    if (state is! LessonLoaded) return;

    final currentState = state as LessonLoaded;

    if (event.type == null) {
      // Clear filter
      emit(currentState.copyWith(
        filteredLessons: currentState.allLessons,
        clearFilter: true,
      ));
    } else {
      // Apply filter
      final filtered = currentState.allLessons
          .where((l) => l.type == event.type)
          .toList();

      emit(currentState.copyWith(
        filteredLessons: filtered,
        filterType: event.type,
      ));
    }
  }

  Future<void> _onMarkCompleted(
    MarkLessonCompleted event,
    Emitter<LessonState> emit,
  ) async {
    if (state is! LessonLoaded) return;

    final currentState = state as LessonLoaded;
    final newCompletedIds = Set<String>.from(currentState.completedLessonIds)
      ..add(event.lessonId);

    // Save to local storage
    await _saveCompletedLessonIds(newCompletedIds);

    emit(currentState.copyWith(completedLessonIds: newCompletedIds));
  }

  Future<void> _onMarkIncomplete(
    MarkLessonIncomplete event,
    Emitter<LessonState> emit,
  ) async {
    if (state is! LessonLoaded) return;

    final currentState = state as LessonLoaded;
    final newCompletedIds = Set<String>.from(currentState.completedLessonIds)
      ..remove(event.lessonId);

    // Save to local storage
    await _saveCompletedLessonIds(newCompletedIds);

    emit(currentState.copyWith(completedLessonIds: newCompletedIds));
  }

  void _onClearFilters(
    ClearLessonFilters event,
    Emitter<LessonState> emit,
  ) {
    if (state is! LessonLoaded) return;

    final currentState = state as LessonLoaded;
    emit(currentState.copyWith(
      filteredLessons: currentState.allLessons,
      clearFilter: true,
    ));
  }

  Future<void> _onRefresh(
    RefreshLessons event,
    Emitter<LessonState> emit,
  ) async {
    if (state is LessonLoaded) {
      final currentState = state as LessonLoaded;
      // Reload completed IDs
      final completedIds = await _loadCompletedLessonIds('');
      emit(currentState.copyWith(completedLessonIds: completedIds));
    }
  }

  /// Set lessons directly (used when lessons are loaded from course)
  void setLessons(List<Video> lessons) {
    _allLessons = lessons;
  }

  Future<Set<String>> _loadCompletedLessonIds(String courseId) async {
    try {
      final box = await Hive.openBox<List<String>>(_completedLessonsBoxName);
      final ids = box.get(courseId, defaultValue: <String>[]) ?? [];
      return ids.toSet();
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveCompletedLessonIds(Set<String> ids) async {
    try {
      final box = await Hive.openBox<List<String>>(_completedLessonsBoxName);
      await box.put('default', ids.toList());
    } catch (e) {
      // Handle error silently
    }
  }
}
