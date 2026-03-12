import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_active_courses.dart';
import '../../../domain/usecases/get_selected_course.dart';
import '../../../domain/usecases/select_course.dart';
import 'courses_event.dart';
import 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final GetActiveCourses getActiveCourses;
  final GetSelectedCourse getSelectedCourse;
  final SelectCourse selectCourse;

  CoursesBloc({
    required this.getActiveCourses,
    required this.getSelectedCourse,
    required this.selectCourse,
  }) : super(const CoursesInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<LoadSelectedCourse>(_onLoadSelectedCourse);
    on<SelectCourseEvent>(_onSelectCourse);
    on<RefreshCourses>(_onRefreshCourses);
  }

  Future<void> _onLoadCourses(
    LoadCourses event,
    Emitter<CoursesState> emit,
  ) async {
    emit(const CoursesLoading());

    final coursesResult = await getActiveCourses();

    await coursesResult.fold(
      (failure) async => emit(CoursesError(failure.message)),
      (courses) async {
        final selectedCourseResult = await getSelectedCourse();

        await selectedCourseResult.fold(
          (failure) async {
            // No course selected, auto-select the default course
            if (courses.isEmpty) {
              emit(CoursesLoaded(courses: courses));
              return;
            }

            final defaultCourse = courses.firstWhere(
              (course) => course.isDefault,
              orElse: () => courses.first,
            );

            // Select the default course
            final selectResult = await selectCourse(defaultCourse.id);

            selectResult.fold(
              (selectFailure) => emit(CoursesLoaded(courses: courses)),
              (_) => emit(CoursesLoaded(
                courses: courses,
                selectedCourse: defaultCourse,
              )),
            );
          },
          (selectedCourse) async => emit(CoursesLoaded(
            courses: courses,
            selectedCourse: selectedCourse,
          )),
        );
      },
    );
  }

  Future<void> _onLoadSelectedCourse(
    LoadSelectedCourse event,
    Emitter<CoursesState> emit,
  ) async {
    final result = await getSelectedCourse();

    await result.fold(
      (failure) async {
        // No course selected, auto-select the default course
        final coursesResult = await getActiveCourses();

        await coursesResult.fold(
          (coursesFailure) async => emit(CoursesError(coursesFailure.message)),
          (courses) async {
            if (courses.isEmpty) {
              emit(const CoursesError('No courses available'));
              return;
            }

            final defaultCourse = courses.firstWhere(
              (course) => course.isDefault,
              orElse: () => courses.first,
            );

            // Select the default course
            final selectResult = await selectCourse(defaultCourse.id);

            selectResult.fold(
              (selectFailure) => emit(CoursesError(selectFailure.message)),
              (_) => emit(SelectedCourseLoaded(defaultCourse)),
            );
          },
        );
      },
      (course) async => emit(SelectedCourseLoaded(course)),
    );
  }

  Future<void> _onSelectCourse(
    SelectCourseEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // Show loading if needed
    if (state is CoursesLoaded) {
      final currentState = state as CoursesLoaded;

      // Select the course
      final selectResult = await selectCourse(event.courseId);

      selectResult.fold(
        (failure) => emit(CoursesError(failure.message)),
        (_) {
          // Find the selected course from the list
          final selectedCourse = currentState.courses.firstWhere(
            (course) => course.id == event.courseId,
            orElse: () => currentState.courses.first,
          );

          emit(CourseSelected(selectedCourse));

          // Update the state with new selection
          emit(currentState.copyWith(selectedCourse: selectedCourse));
        },
      );
    }
  }

  Future<void> _onRefreshCourses(
    RefreshCourses event,
    Emitter<CoursesState> emit,
  ) async {
    // Keep current state while refreshing
    final coursesResult = await getActiveCourses();
    final selectedCourseResult = await getSelectedCourse();

    coursesResult.fold(
      (failure) => emit(CoursesError(failure.message)),
      (courses) {
        selectedCourseResult.fold(
          (failure) => emit(CoursesLoaded(courses: courses)),
          (selectedCourse) => emit(CoursesLoaded(
            courses: courses,
            selectedCourse: selectedCourse,
          )),
        );
      },
    );
  }
}
