/// Enum representing the different types of lessons available in the app.
///
/// Each lesson type has specific UI rendering and data requirements.
enum LessonType {
  /// Video lesson with video playback
  video,

  /// Audio lesson for podcasts, guided meditations, etc.
  audio,

  /// Text/article lesson with rich text content (Quill Delta JSON)
  text,

  /// Interactive quiz with multiple choice questions
  quiz,

  /// Flashcard deck for memorization
  flashcard;

  /// Parse lesson type from Firestore string value
  /// Defaults to [video] for backward compatibility
  static LessonType fromString(String? value) {
    if (value == null || value.isEmpty) return LessonType.video;

    switch (value.toLowerCase()) {
      case 'video':
        return LessonType.video;
      case 'audio':
        return LessonType.audio;
      case 'text':
        return LessonType.text;
      case 'quiz':
        return LessonType.quiz;
      case 'flashcard':
        return LessonType.flashcard;
      default:
        return LessonType.video; // Default for backward compatibility
    }
  }

  /// Convert to Firestore string value
  String toFirestoreValue() {
    return name;
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case LessonType.video:
        return 'Video';
      case LessonType.audio:
        return 'Audio';
      case LessonType.text:
        return 'Article';
      case LessonType.quiz:
        return 'Quiz';
      case LessonType.flashcard:
        return 'Flashcards';
    }
  }

  /// Get icon name (Flutter Icons) for this lesson type
  String get iconName {
    switch (this) {
      case LessonType.video:
        return 'play_circle';
      case LessonType.audio:
        return 'headphones';
      case LessonType.text:
        return 'article';
      case LessonType.quiz:
        return 'quiz';
      case LessonType.flashcard:
        return 'style';
    }
  }

  /// Whether this lesson type has media playback (video/audio)
  bool get isMediaType => this == LessonType.video || this == LessonType.audio;

  /// Whether this lesson type has interactive content (quiz/flashcard)
  bool get isInteractiveType => this == LessonType.quiz || this == LessonType.flashcard;

  /// Whether this lesson type is reading content
  bool get isReadingType => this == LessonType.text;
}
