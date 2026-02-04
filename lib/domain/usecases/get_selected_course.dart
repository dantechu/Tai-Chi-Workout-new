import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/course.dart';
import '../repositories/course_repository.dart';

class GetSelectedCourse {
  final CourseRepository repository;

  GetSelectedCourse(this.repository);

  Future<Either<Failure, Course>> call() async {
    return await repository.getSelectedCourse();
  }
}
