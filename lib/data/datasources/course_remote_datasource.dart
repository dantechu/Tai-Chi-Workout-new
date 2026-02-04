import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

abstract class CourseRemoteDataSource {
  /// Fetch all active courses from Firestore
  Future<List<CourseModel>> getActiveCourses();

  /// Fetch a specific course by ID
  Future<CourseModel> getCourseById(String courseId);

  /// Get the default course
  Future<CourseModel> getDefaultCourse();

  /// Stream of active courses (real-time updates)
  Stream<List<CourseModel>> watchActiveCourses();
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final FirebaseFirestore firestore;

  CourseRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<CourseModel>> getActiveCourses() async {
    try {
      final snapshot = await firestore
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active courses: $e');
    }
  }

  @override
  Future<CourseModel> getCourseById(String courseId) async {
    try {
      final doc = await firestore.collection('courses').doc(courseId).get();

      if (!doc.exists) {
        throw Exception('Course not found: $courseId');
      }

      return CourseModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch course: $e');
    }
  }

  @override
  Future<CourseModel> getDefaultCourse() async {
    try {
      final snapshot = await firestore
          .collection('courses')
          .where('isDefault', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No default course found');
      }

      return CourseModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to fetch default course: $e');
    }
  }

  @override
  Stream<List<CourseModel>> watchActiveCourses() {
    return firestore
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseModel.fromFirestore(doc))
            .toList());
  }
}
