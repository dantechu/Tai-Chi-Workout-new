import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_local_datasource.dart';
import '../datasources/course_remote_datasource.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;
  final CourseLocalDataSource localDataSource;

  CourseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Course>>> getActiveCourses() async {
    try {
      // Try to fetch from remote
      final courses = await remoteDataSource.getActiveCourses();

      // Cache the courses
      await localDataSource.cacheCourses(courses);

      return Right(courses.map((model) => model.toEntity()).toList());
    } catch (e) {
      // If remote fails, try cache
      try {
        final cachedCourses = await localDataSource.getCachedCourses();
        if (cachedCourses != null && cachedCourses.isNotEmpty) {
          return Right(
              cachedCourses.map((model) => model.toEntity()).toList());
        }
      } catch (_) {}

      return Left(ServerFailure('Failed to fetch courses: $e'));
    }
  }

  @override
  Future<Either<Failure, Course>> getCourseById(String courseId) async {
    try {
      // Try remote first
      final course = await remoteDataSource.getCourseById(courseId);

      // Cache it
      await localDataSource.cacheCourse(course);

      return Right(course.toEntity());
    } catch (e) {
      // Try cache
      try {
        final cachedCourse = await localDataSource.getCachedCourse(courseId);
        if (cachedCourse != null) {
          return Right(cachedCourse.toEntity());
        }
      } catch (_) {}

      return Left(ServerFailure('Failed to fetch course: $e'));
    }
  }

  @override
  Future<Either<Failure, Course>> getDefaultCourse() async {
    try {
      final course = await remoteDataSource.getDefaultCourse();
      await localDataSource.cacheCourse(course);
      return Right(course.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to fetch default course: $e'));
    }
  }

  @override
  Future<Either<Failure, Course>> getSelectedCourse() async {
    try {
      // Check if there's a selected course ID
      final selectedId = await localDataSource.getSelectedCourseId();

      if (selectedId != null) {
        // Get the selected course
        return await getCourseById(selectedId);
      } else {
        // No selection, return default course
        final defaultCourse = await getDefaultCourse();

        // Save it as selected
        defaultCourse.fold(
          (l) => null,
          (course) => localDataSource.setSelectedCourseId(course.id),
        );

        return defaultCourse;
      }
    } catch (e) {
      return Left(CacheFailure('Failed to get selected course: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> selectCourse(String courseId) async {
    try {
      await localDataSource.setSelectedCourseId(courseId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to select course: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Course>>> watchActiveCourses() {
    try {
      return remoteDataSource.watchActiveCourses().map(
            (courses) => Right<Failure, List<Course>>(
              courses.map((model) => model.toEntity()).toList(),
            ),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to watch courses: $e')),
      );
    }
  }
}
