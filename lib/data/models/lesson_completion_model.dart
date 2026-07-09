import '../../domain/entities/lesson_completion.dart';

class LessonCompletionModel extends LessonCompletion {
  const LessonCompletionModel({
    required super.id,
    required super.lessonId,
    required super.completedAt,
    super.scorePercentage,
  });

  factory LessonCompletionModel.fromJson(Map<String, dynamic> json) {
    return LessonCompletionModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      scorePercentage: json['scorePercentage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'completedAt': completedAt.toIso8601String(),
      'scorePercentage': scorePercentage,
    };
  }

  factory LessonCompletionModel.fromEntity(LessonCompletion entity) {
    return LessonCompletionModel(
      id: entity.id,
      lessonId: entity.lessonId,
      completedAt: entity.completedAt,
      scorePercentage: entity.scorePercentage,
    );
  }

  factory LessonCompletionModel.create(String lessonId, {int? scorePercentage}) {
    return LessonCompletionModel(
      id: '${lessonId}_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: lessonId,
      completedAt: DateTime.now(),
      scorePercentage: scorePercentage,
    );
  }

  LessonCompletion toEntity() {
    return LessonCompletion(
      id: id,
      lessonId: lessonId,
      completedAt: completedAt,
      scorePercentage: scorePercentage,
    );
  }
}
