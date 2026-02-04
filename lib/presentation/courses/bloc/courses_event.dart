import 'package:equatable/equatable.dart';

abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all active courses
class LoadCourses extends CoursesEvent {
  const LoadCourses();
}

/// Load the selected course
class LoadSelectedCourse extends CoursesEvent {
  const LoadSelectedCourse();
}

/// Select a specific course
class SelectCourseEvent extends CoursesEvent {
  final String courseId;

  const SelectCourseEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// Refresh courses from server
class RefreshCourses extends CoursesEvent {
  const RefreshCourses();
}
