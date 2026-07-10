import 'package:equatable/equatable.dart';

/// Entity representing a completed lesson.
class LessonCompletion extends Equatable {
  final String id;
  final String lessonId;
  final String? courseId;
  final DateTime completedAt;
  final int? scorePercentage; // For quiz/flashcard, null for video/audio/text
  final String? lessonType; // video, audio, text, quiz, flashcard
  final int? durationSeconds; // Duration of the lesson for time tracking

  const LessonCompletion({
    required this.id,
    required this.lessonId,
    this.courseId,
    required this.completedAt,
    this.scorePercentage,
    this.lessonType,
    this.durationSeconds,
  });

  @override
  List<Object?> get props => [
        id,
        lessonId,
        courseId,
        completedAt,
        scorePercentage,
        lessonType,
        durationSeconds,
      ];
}
