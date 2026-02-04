import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/course.dart';
import '../repositories/course_repository.dart';

class GetActiveCourses {
  final CourseRepository repository;

  GetActiveCourses(this.repository);

  Future<Either<Failure, List<Course>>> call() async {
    return await repository.getActiveCourses();
  }
}
