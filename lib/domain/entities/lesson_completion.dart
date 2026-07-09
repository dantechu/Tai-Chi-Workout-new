import 'package:equatable/equatable.dart';

/// Entity representing a completed lesson.
class LessonCompletion extends Equatable {
  final String id;
  final String lessonId;
  final DateTime completedAt;
  final int? scorePercentage; // For quiz/flashcard, null for video/audio/text

  const LessonCompletion({
    required this.id,
    required this.lessonId,
    required this.completedAt,
    this.scorePercentage,
  });

  @override
  List<Object?> get props => [id, lessonId, completedAt, scorePercentage];
}
