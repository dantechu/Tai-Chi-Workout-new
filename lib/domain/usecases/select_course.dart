import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/course_repository.dart';

class SelectCourse {
  final CourseRepository repository;

  SelectCourse(this.repository);

  Future<Either<Failure, void>> call(String courseId) async {
    return await repository.selectCourse(courseId);
  }
}
