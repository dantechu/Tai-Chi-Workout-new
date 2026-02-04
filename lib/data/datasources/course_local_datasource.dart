import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../../core/constants/app_constants.dart';

abstract class CourseLocalDataSource {
  /// Cache courses locally
  Future<void> cacheCourses(List<CourseModel> courses);

  /// Get cached courses
  Future<List<CourseModel>?> getCachedCourses();

  /// Cache a single course
  Future<void> cacheCourse(CourseModel course);

  /// Get cached course by ID
  Future<CourseModel?> getCachedCourse(String courseId);

  /// Save selected course ID
  Future<void> setSelectedCourseId(String courseId);

  /// Get selected course ID
  Future<String?> getSelectedCourseId();

  /// Clear all cached courses
  Future<void> clearCache();
}

class CourseLocalDataSourceImpl implements CourseLocalDataSource {
  final SharedPreferences sharedPreferences;

  CourseLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheCourses(List<CourseModel> courses) async {
    try {
      final box = await Hive.openBox(AppConstants.hiveCoursesBox);

      // Clear existing courses
      await box.clear();

      // Cache new courses - use toHiveMap() to avoid Firestore-specific types
      for (var course in courses) {
        await box.put(course.id, course.toHiveMap());
      }
    } catch (e) {
      throw Exception('Failed to cache courses: $e');
    }
  }

  @override
  Future<List<CourseModel>?> getCachedCourses() async {
    try {
      final box = await Hive.openBox(AppConstants.hiveCoursesBox);

      if (box.isEmpty) {
        return null;
      }

      final courses = <CourseModel>[];
      for (var key in box.keys) {
        final data = box.get(key) as Map<dynamic, dynamic>;
        final courseMap = Map<String, dynamic>.from(data);
        courses.add(CourseModel.fromMap(courseMap, key.toString()));
      }

      // Sort by order
      courses.sort((a, b) => a.order.compareTo(b.order));

      return courses;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCourse(CourseModel course) async {
    try {
      final box = await Hive.openBox(AppConstants.hiveCoursesBox);
      await box.put(course.id, course.toHiveMap());
    } catch (e) {
      throw Exception('Failed to cache course: $e');
    }
  }

  @override
  Future<CourseModel?> getCachedCourse(String courseId) async {
    try {
      final box = await Hive.openBox(AppConstants.hiveCoursesBox);
      final data = box.get(courseId);

      if (data == null) {
        return null;
      }

      final courseMap = Map<String, dynamic>.from(data as Map);
      return CourseModel.fromMap(courseMap, courseId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setSelectedCourseId(String courseId) async {
    await sharedPreferences.setString(
      AppConstants.selectedCourseKey,
      courseId,
    );
  }

  @override
  Future<String?> getSelectedCourseId() async {
    return sharedPreferences.getString(AppConstants.selectedCourseKey);
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox(AppConstants.hiveCoursesBox);
      await box.clear();
      await sharedPreferences.remove(AppConstants.selectedCourseKey);
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }
}
