import 'package:equatable/equatable.dart';
import '../../../domain/entities/course.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

/// Loading courses
class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

/// Courses loaded successfully
class CoursesLoaded extends CoursesState {
  final List<Course> courses;
  final Course? selectedCourse;

  const CoursesLoaded({
    required this.courses,
    this.selectedCourse,
  });

  CoursesLoaded copyWith({
    List<Course>? courses,
    Course? selectedCourse,
  }) {
    return CoursesLoaded(
      courses: courses ?? this.courses,
      selectedCourse: selectedCourse ?? this.selectedCourse,
    );
  }

  @override
  List<Object?> get props => [courses, selectedCourse];
}

/// Selected course loaded
class SelectedCourseLoaded extends CoursesState {
  final Course course;

  const SelectedCourseLoaded(this.course);

  @override
  List<Object?> get props => [course];
}

/// Course selected successfully
class CourseSelected extends CoursesState {
  final Course course;

  const CourseSelected(this.course);

  @override
  List<Object?> get props => [course];
}

/// Error state
class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
