import 'package:equatable/equatable.dart';
import 'video.dart';
import 'lesson_type.dart';

/// Domain entity representing a section within a course.
///
/// Sections contain lessons of various types (video, audio, text, quiz, flashcard).
class Section extends Equatable {
  final String id;
  final int sectionNumber;
  final String title;
  final String description;
  final int order;
  final List<Video> videos;

  // Multi-language support fields
  final String? titleDe;
  final String? titleEs;
  final String? titleFr;
  final String? titleJa;
  final String? titleKo;
  final String? titleZh;

  const Section({
    required this.id,
    required this.sectionNumber,
    required this.title,
    required this.description,
    required this.order,
    required this.videos,
    // Multi-language support
    this.titleDe,
    this.titleEs,
    this.titleFr,
    this.titleJa,
    this.titleKo,
    this.titleZh,
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

  /// Alias for videos list - all lessons regardless of type
  List<Video> get lessons => videos;

  /// Get total duration of all lessons in this section
  Duration get totalDuration {
    return videos.fold(
      Duration.zero,
      (total, video) => total + video.estimatedDuration,
    );
  }

  /// Get total lesson count
  int get lessonCount => videos.length;

  /// Get video count (legacy compatibility)
  int get videoCount => getLessonCountByType(LessonType.video);

  /// Get premium video count (all premium lessons)
  int get premiumVideoCount => videos.where((video) => video.isPremium).length;

  /// Get free video count (all free lessons)
  int get freeVideoCount => videos.where((video) => !video.isPremium).length;

  /// Check if section has any premium lessons
  bool get hasAnyPremiumVideos => premiumVideoCount > 0;

  /// Check if all lessons are premium
  bool get hasOnlyPremiumVideos =>
      premiumVideoCount == lessonCount && lessonCount > 0;

  /// Check if all lessons are free
  bool get hasOnlyFreeVideos =>
      freeVideoCount == lessonCount && lessonCount > 0;

  /// Get free lessons
  List<Video> get freeVideos =>
      videos.where((video) => !video.isPremium).toList();

  /// Get premium lessons
  List<Video> get premiumVideos =>
      videos.where((video) => video.isPremium).toList();

  // === Lesson Type Helpers ===

  /// Get lessons filtered by type
  List<Video> getLessonsByType(LessonType type) {
    return videos.where((v) => v.type == type).toList();
  }

  /// Get count of lessons by type
  int getLessonCountByType(LessonType type) {
    return videos.where((v) => v.type == type).length;
  }

  /// Get video lessons only
  List<Video> get videoLessons => getLessonsByType(LessonType.video);

  /// Get audio lessons only
  List<Video> get audioLessons => getLessonsByType(LessonType.audio);

  /// Get text lessons only
  List<Video> get textLessons => getLessonsByType(LessonType.text);

  /// Get quiz lessons only
  List<Video> get quizLessons => getLessonsByType(LessonType.quiz);

  /// Get flashcard lessons only
  List<Video> get flashcardLessons => getLessonsByType(LessonType.flashcard);

  /// Get count of each lesson type
  Map<LessonType, int> get lessonTypeCounts {
    final counts = <LessonType, int>{};
    for (final type in LessonType.values) {
      final count = getLessonCountByType(type);
      if (count > 0) {
        counts[type] = count;
      }
    }
    return counts;
  }

  /// Check if section has lessons of a specific type
  bool hasLessonType(LessonType type) => getLessonCountByType(type) > 0;

  /// Check if section has video lessons
  bool get hasVideoLessons => hasLessonType(LessonType.video);

  /// Check if section has audio lessons
  bool get hasAudioLessons => hasLessonType(LessonType.audio);

  /// Check if section has text lessons
  bool get hasTextLessons => hasLessonType(LessonType.text);

  /// Check if section has quiz lessons
  bool get hasQuizLessons => hasLessonType(LessonType.quiz);

  /// Check if section has flashcard lessons
  bool get hasFlashcardLessons => hasLessonType(LessonType.flashcard);

  /// Get a summary string of lesson types (e.g., "3 videos, 2 quizzes")
  String getLessonTypeSummary() {
    final parts = <String>[];
    final counts = lessonTypeCounts;

    for (final type in LessonType.values) {
      final count = counts[type];
      if (count != null && count > 0) {
        final label = count == 1 ? type.displayName : '${type.displayName}s';
        parts.add('$count $label');
      }
    }

    return parts.join(', ');
  }

  Section copyWith({
    String? id,
    int? sectionNumber,
    String? title,
    String? description,
    int? order,
    List<Video>? videos,
    String? titleDe,
    String? titleEs,
    String? titleFr,
    String? titleJa,
    String? titleKo,
    String? titleZh,
  }) {
    return Section(
      id: id ?? this.id,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      videos: videos ?? this.videos,
      titleDe: titleDe ?? this.titleDe,
      titleEs: titleEs ?? this.titleEs,
      titleFr: titleFr ?? this.titleFr,
      titleJa: titleJa ?? this.titleJa,
      titleKo: titleKo ?? this.titleKo,
      titleZh: titleZh ?? this.titleZh,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sectionNumber,
        title,
        description,
        order,
        videos,
        titleDe,
        titleEs,
        titleFr,
        titleJa,
        titleKo,
        titleZh,
      ];

  @override
  String toString() {
    return 'Section(id: $id, number: $sectionNumber, title: $title, lessons: $lessonCount)';
  }
}
