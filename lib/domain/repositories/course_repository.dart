import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/course.dart';

abstract class CourseRepository {
  /// Get all active courses (remote with local cache fallback)
  Future<Either<Failure, List<Course>>> getActiveCourses();

  /// Get a specific course by ID
  Future<Either<Failure, Course>> getCourseById(String courseId);

  /// Get the default course
  Future<Either<Failure, Course>> getDefaultCourse();

  /// Get the currently selected course
  Future<Either<Failure, Course>> getSelectedCourse();

  /// Set the selected course
  Future<Either<Failure, void>> selectCourse(String courseId);

  /// Stream of active courses (real-time updates)
  Stream<Either<Failure, List<Course>>> watchActiveCourses();
}
