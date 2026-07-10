import '../../domain/entities/lesson_completion.dart';

class LessonCompletionModel extends LessonCompletion {
  const LessonCompletionModel({
    required super.id,
    required super.lessonId,
    super.courseId,
    required super.completedAt,
    super.scorePercentage,
    super.lessonType,
    super.durationSeconds,
  });

  factory LessonCompletionModel.fromJson(Map<String, dynamic> json) {
    return LessonCompletionModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      courseId: json['courseId'] as String?,
      completedAt: DateTime.parse(json['completedAt'] as String),
      scorePercentage: json['scorePercentage'] as int?,
      lessonType: json['lessonType'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'courseId': courseId,
      'completedAt': completedAt.toIso8601String(),
      'scorePercentage': scorePercentage,
      'lessonType': lessonType,
      'durationSeconds': durationSeconds,
    };
  }

  factory LessonCompletionModel.fromEntity(LessonCompletion entity) {
    return LessonCompletionModel(
      id: entity.id,
      lessonId: entity.lessonId,
      courseId: entity.courseId,
      completedAt: entity.completedAt,
      scorePercentage: entity.scorePercentage,
      lessonType: entity.lessonType,
      durationSeconds: entity.durationSeconds,
    );
  }

  factory LessonCompletionModel.create(
    String lessonId, {
    String? courseId,
    int? scorePercentage,
    String? lessonType,
    int? durationSeconds,
  }) {
    return LessonCompletionModel(
      id: '${lessonId}_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: lessonId,
      courseId: courseId,
      completedAt: DateTime.now(),
      scorePercentage: scorePercentage,
      lessonType: lessonType,
      durationSeconds: durationSeconds,
    );
  }

  LessonCompletion toEntity() {
    return LessonCompletion(
      id: id,
      lessonId: lessonId,
      courseId: courseId,
      completedAt: completedAt,
      scorePercentage: scorePercentage,
      lessonType: lessonType,
      durationSeconds: durationSeconds,
    );
  }
}
