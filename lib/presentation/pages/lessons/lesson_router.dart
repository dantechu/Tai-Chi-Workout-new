import 'package:flutter/material.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/entities/section.dart';
import '../../../domain/entities/lesson_type.dart';
import '../video_player/video_player_page.dart';
import '../audio_lesson/audio_lesson_page.dart';
import '../text_lesson/text_lesson_page.dart';
import '../quiz/quiz_page.dart';
import '../flashcard/flashcard_page.dart';

/// Utility class for routing to the appropriate lesson page based on type.
///
/// Handles navigation for all 5 lesson types:
/// - Video: VideoPlayerPage
/// - Audio: AudioLessonPage
/// - Text: TextLessonPage
/// - Quiz: QuizPage
/// - Flashcard: FlashcardPage
class LessonRouter {
  /// Navigate to the appropriate lesson page based on lesson type.
  static void navigateToLesson(
    BuildContext context,
    Video lesson, {
    List<Section>? sections,
  }) {
    final page = _buildLessonPage(
      lesson,
      sections: sections,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Push and replace the current page with the lesson page.
  static void replaceWithLesson(
    BuildContext context,
    Video lesson, {
    List<Section>? sections,
  }) {
    final page = _buildLessonPage(
      lesson,
      sections: sections,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Build the appropriate page widget for a lesson type.
  static Widget _buildLessonPage(
    Video lesson, {
    List<Section>? sections,
  }) {
    switch (lesson.type) {
      case LessonType.video:
        return VideoPlayerPage(
          video: lesson,
          sections: sections,
        );

      case LessonType.audio:
        return AudioLessonPage(
          lesson: lesson,
          sections: sections,
        );

      case LessonType.text:
        return TextLessonPage(
          lesson: lesson,
          sections: sections,
        );

      case LessonType.quiz:
        return QuizPage(
          lesson: lesson,
          sections: sections,
        );

      case LessonType.flashcard:
        return FlashcardPage(
          lesson: lesson,
          sections: sections,
        );
    }
  }

  /// Get the page widget without navigation (for use in tabs, etc.)
  static Widget buildLessonPage(
    Video lesson, {
    List<Section>? sections,
  }) {
    return _buildLessonPage(
      lesson,
      sections: sections,
    );
  }

  /// Check if a lesson can be played (has valid content).
  static bool canPlayLesson(Video lesson) {
    switch (lesson.type) {
      case LessonType.video:
        return lesson.videoUrl?.isNotEmpty == true;

      case LessonType.audio:
        return lesson.audioUrl?.isNotEmpty == true;

      case LessonType.text:
        return lesson.content?.isNotEmpty == true;

      case LessonType.quiz:
        return lesson.questions?.isNotEmpty == true;

      case LessonType.flashcard:
        return lesson.cards?.isNotEmpty == true;
    }
  }

  /// Get an error message if lesson cannot be played.
  static String? getCannotPlayReason(Video lesson) {
    if (canPlayLesson(lesson)) return null;

    switch (lesson.type) {
      case LessonType.video:
        return 'No video URL available';

      case LessonType.audio:
        return 'No audio URL available';

      case LessonType.text:
        return 'No content available';

      case LessonType.quiz:
        return 'No questions available';

      case LessonType.flashcard:
        return 'No flashcards available';
    }
  }
}

/// Extension on BuildContext for easier navigation.
extension LessonRouterExtension on BuildContext {
  /// Navigate to a lesson using the LessonRouter.
  void navigateToLesson(
    Video lesson, {
    List<Section>? sections,
  }) {
    LessonRouter.navigateToLesson(
      this,
      lesson,
      sections: sections,
    );
  }
}
