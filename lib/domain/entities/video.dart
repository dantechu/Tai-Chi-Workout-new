import 'package:equatable/equatable.dart';
import 'lesson_type.dart';
import 'quiz_question.dart';
import 'flash_card.dart';

/// Domain entity representing a lesson (video, audio, text, quiz, or flashcard).
///
/// This entity supports all 5 lesson types while maintaining backward compatibility
/// with video-only data structures. The [type] field determines which fields are relevant.
class Video extends Equatable {
  // === Common Fields (All Lesson Types) ===
  final String id;
  final String title;
  final LessonType type;
  final int sectionNumber;
  final int rowNumber;
  final Duration duration;
  final bool isPremium;
  final String? description;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? courseId;
  final String? thumbnailUrl;

  // === Video-specific Fields ===
  final String? videoUrl;
  final String category; // Legacy field for video categorization

  // === Audio-specific Fields ===
  final String? audioUrl;

  // === Text Lesson Fields ===
  /// Quill Delta JSON content for text lessons
  final String? content;
  /// Banner image URL displayed at top of text lessons
  final String? bannerUrl;
  /// Estimated reading time in seconds
  final int? estimatedReadTime;

  // === Quiz Fields ===
  final List<QuizQuestion>? questions;
  /// Pass threshold percentage (default: 70)
  final int? passingPercentage;

  // === Flashcard Fields ===
  final List<FlashCard>? cards;

  // === Multi-language Support: Titles ===
  final String? titleDe;
  final String? titleEs;
  final String? titleFr;
  final String? titleJa;
  final String? titleKo;
  final String? titleZh;

  // === Multi-language Support: Descriptions ===
  final String? descriptionDe;
  final String? descriptionEs;
  final String? descriptionFr;
  final String? descriptionJa;
  final String? descriptionKo;
  final String? descriptionZh;

  // === Multi-language Support: Text Content ===
  final String? contentDe;
  final String? contentEs;
  final String? contentFr;
  final String? contentJa;
  final String? contentKo;
  final String? contentZh;

  const Video({
    required this.id,
    required this.title,
    this.type = LessonType.video,
    this.category = '',
    this.videoUrl,
    this.thumbnailUrl,
    required this.sectionNumber,
    required this.rowNumber,
    required this.duration,
    this.isPremium = false,
    this.description,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
    this.courseId,
    // Audio
    this.audioUrl,
    // Text
    this.content,
    this.bannerUrl,
    this.estimatedReadTime,
    // Quiz
    this.questions,
    this.passingPercentage,
    // Flashcard
    this.cards,
    // Multi-language titles
    this.titleDe,
    this.titleEs,
    this.titleFr,
    this.titleJa,
    this.titleKo,
    this.titleZh,
    // Multi-language descriptions
    this.descriptionDe,
    this.descriptionEs,
    this.descriptionFr,
    this.descriptionJa,
    this.descriptionKo,
    this.descriptionZh,
    // Multi-language content
    this.contentDe,
    this.contentEs,
    this.contentFr,
    this.contentJa,
    this.contentKo,
    this.contentZh,
  });

  /// Get localized title based on language code
  String getLocalizedTitle(String languageCode) {
    switch (languageCode) {
      case 'de':
        return titleDe?.isNotEmpty == true ? titleDe! : title;
      case 'es':
        return titleEs?.isNotEmpty == true ? titleEs! : title;
      case 'fr':
        return titleFr?.isNotEmpty == true ? titleFr! : title;
      case 'ja':
        return titleJa?.isNotEmpty == true ? titleJa! : title;
      case 'ko':
        return titleKo?.isNotEmpty == true ? titleKo! : title;
      case 'zh':
        return titleZh?.isNotEmpty == true ? titleZh! : title;
      default:
        return title;
    }
  }

  /// Get localized description based on language code
  String? getLocalizedDescription(String languageCode) {
    switch (languageCode) {
      case 'de':
        return descriptionDe?.isNotEmpty == true ? descriptionDe : description;
      case 'es':
        return descriptionEs?.isNotEmpty == true ? descriptionEs : description;
      case 'fr':
        return descriptionFr?.isNotEmpty == true ? descriptionFr : description;
      case 'ja':
        return descriptionJa?.isNotEmpty == true ? descriptionJa : description;
      case 'ko':
        return descriptionKo?.isNotEmpty == true ? descriptionKo : description;
      case 'zh':
        return descriptionZh?.isNotEmpty == true ? descriptionZh : description;
      default:
        return description;
    }
  }

  /// Get localized content (for text lessons) based on language code
  String? getLocalizedContent(String languageCode) {
    switch (languageCode) {
      case 'de':
        return contentDe?.isNotEmpty == true ? contentDe : content;
      case 'es':
        return contentEs?.isNotEmpty == true ? contentEs : content;
      case 'fr':
        return contentFr?.isNotEmpty == true ? contentFr : content;
      case 'ja':
        return contentJa?.isNotEmpty == true ? contentJa : content;
      case 'ko':
        return contentKo?.isNotEmpty == true ? contentKo : content;
      case 'zh':
        return contentZh?.isNotEmpty == true ? contentZh : content;
      default:
        return content;
    }
  }

  /// Get the estimated duration for this lesson based on type
  Duration get estimatedDuration {
    switch (type) {
      case LessonType.video:
      case LessonType.audio:
        return duration;
      case LessonType.text:
        return Duration(seconds: estimatedReadTime ?? duration.inSeconds);
      case LessonType.quiz:
        // 30 seconds per question
        return Duration(seconds: (questions?.length ?? 0) * 30);
      case LessonType.flashcard:
        // 10 seconds per card
        return Duration(seconds: (cards?.length ?? 0) * 10);
    }
  }

  /// Get a subtitle string for display (duration, question count, etc.)
  String getSubtitle() {
    switch (type) {
      case LessonType.video:
      case LessonType.audio:
        return _formatDuration(duration);
      case LessonType.text:
        final minutes = ((estimatedReadTime ?? duration.inSeconds) / 60).ceil();
        return '$minutes min read';
      case LessonType.quiz:
        final count = questions?.length ?? 0;
        return '$count question${count != 1 ? 's' : ''}';
      case LessonType.flashcard:
        final count = cards?.length ?? 0;
        return '$count card${count != 1 ? 's' : ''}';
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get the media URL (video or audio) for playback
  String? get mediaUrl {
    switch (type) {
      case LessonType.video:
        return videoUrl;
      case LessonType.audio:
        return audioUrl;
      default:
        return null;
    }
  }

  /// Check if this lesson has playable media
  bool get hasMedia => mediaUrl?.isNotEmpty == true;

  /// Check if this is a video lesson
  bool get isVideo => type == LessonType.video;

  /// Check if this is an audio lesson
  bool get isAudio => type == LessonType.audio;

  /// Check if this is a text lesson
  bool get isText => type == LessonType.text;

  /// Check if this is a quiz lesson
  bool get isQuiz => type == LessonType.quiz;

  /// Check if this is a flashcard lesson
  bool get isFlashcard => type == LessonType.flashcard;

  Video copyWith({
    String? id,
    String? title,
    LessonType? type,
    String? category,
    String? videoUrl,
    String? thumbnailUrl,
    int? sectionNumber,
    int? rowNumber,
    Duration? duration,
    bool? isPremium,
    String? description,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? courseId,
    String? audioUrl,
    String? content,
    String? bannerUrl,
    int? estimatedReadTime,
    List<QuizQuestion>? questions,
    int? passingPercentage,
    List<FlashCard>? cards,
    String? titleDe,
    String? titleEs,
    String? titleFr,
    String? titleJa,
    String? titleKo,
    String? titleZh,
    String? descriptionDe,
    String? descriptionEs,
    String? descriptionFr,
    String? descriptionJa,
    String? descriptionKo,
    String? descriptionZh,
    String? contentDe,
    String? contentEs,
    String? contentFr,
    String? contentJa,
    String? contentKo,
    String? contentZh,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      category: category ?? this.category,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      rowNumber: rowNumber ?? this.rowNumber,
      duration: duration ?? this.duration,
      isPremium: isPremium ?? this.isPremium,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      courseId: courseId ?? this.courseId,
      audioUrl: audioUrl ?? this.audioUrl,
      content: content ?? this.content,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      estimatedReadTime: estimatedReadTime ?? this.estimatedReadTime,
      questions: questions ?? this.questions,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      cards: cards ?? this.cards,
      titleDe: titleDe ?? this.titleDe,
      titleEs: titleEs ?? this.titleEs,
      titleFr: titleFr ?? this.titleFr,
      titleJa: titleJa ?? this.titleJa,
      titleKo: titleKo ?? this.titleKo,
      titleZh: titleZh ?? this.titleZh,
      descriptionDe: descriptionDe ?? this.descriptionDe,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      descriptionJa: descriptionJa ?? this.descriptionJa,
      descriptionKo: descriptionKo ?? this.descriptionKo,
      descriptionZh: descriptionZh ?? this.descriptionZh,
      contentDe: contentDe ?? this.contentDe,
      contentEs: contentEs ?? this.contentEs,
      contentFr: contentFr ?? this.contentFr,
      contentJa: contentJa ?? this.contentJa,
      contentKo: contentKo ?? this.contentKo,
      contentZh: contentZh ?? this.contentZh,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        category,
        videoUrl,
        thumbnailUrl,
        sectionNumber,
        rowNumber,
        duration,
        isPremium,
        description,
        tags,
        createdAt,
        updatedAt,
        courseId,
        audioUrl,
        content,
        bannerUrl,
        estimatedReadTime,
        questions,
        passingPercentage,
        cards,
        titleDe,
        titleEs,
        titleFr,
        titleJa,
        titleKo,
        titleZh,
        descriptionDe,
        descriptionEs,
        descriptionFr,
        descriptionJa,
        descriptionKo,
        descriptionZh,
        contentDe,
        contentEs,
        contentFr,
        contentJa,
        contentKo,
        contentZh,
      ];

  @override
  String toString() {
    return 'Video(id: $id, title: $title, type: ${type.name}, duration: $duration, isPremium: $isPremium)';
  }
}
