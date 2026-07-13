import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/lesson_type.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/flash_card.dart';
import 'quiz_question_model.dart';
import 'flash_card_model.dart';

/// Data model for Video/Lesson that handles Firestore serialization.
///
/// Supports all 5 lesson types: video, audio, text, quiz, flashcard.
class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    super.type = LessonType.video,
    super.category = '',
    super.videoUrl,
    super.thumbnailUrl,
    required super.sectionNumber,
    required super.rowNumber,
    required super.duration,
    super.isPremium = false,
    super.description,
    super.tags = const [],
    super.createdAt,
    super.updatedAt,
    super.courseId,
    // Audio
    super.audioUrl,
    // Text
    super.content,
    super.bannerUrl,
    super.estimatedReadTime,
    // Quiz
    super.questions,
    super.passingPercentage,
    // Flashcard
    super.cards,
    // Multi-language titles
    super.titleDe,
    super.titleEs,
    super.titleFr,
    super.titleJa,
    super.titleKo,
    super.titleZh,
    // Multi-language descriptions
    super.descriptionDe,
    super.descriptionEs,
    super.descriptionFr,
    super.descriptionJa,
    super.descriptionKo,
    super.descriptionZh,
    // Multi-language content
    super.contentDe,
    super.contentEs,
    super.contentFr,
    super.contentJa,
    super.contentKo,
    super.contentZh,
  });

  /// Create from Map (Firestore compatible)
  factory VideoModel.fromMap(Map<String, dynamic> map) {
    // Parse lesson type - default to video for backward compatibility
    final type = LessonType.fromString(map['type'] as String?);

    // Generate ID from type, section, and row if not provided
    final typePrefix = type.name;
    final id = map['id'] as String? ??
        '${typePrefix}_${map['sectionNumber']}_${map['rowNumber'] ?? map['row']}';

    // Parse questions for quiz type
    // Note: When reading from Hive cache, nested maps are Map<dynamic, dynamic>
    // so we need to convert them to Map<String, dynamic>
    List<QuizQuestion>? questions;
    if (type == LessonType.quiz && map['questions'] != null) {
      questions = (map['questions'] as List<dynamic>)
          .map((q) => QuizQuestionModel.fromMap(
              Map<String, dynamic>.from(q as Map)).toEntity())
          .toList();
    }

    // Parse cards for flashcard type
    // Note: When reading from Hive cache, nested maps are Map<dynamic, dynamic>
    // so we need to convert them to Map<String, dynamic>
    List<FlashCard>? cards;
    if (type == LessonType.flashcard && map['cards'] != null) {
      cards = (map['cards'] as List<dynamic>)
          .map((c) => FlashCardModel.fromMap(
              Map<String, dynamic>.from(c as Map)).toEntity())
          .toList();
    }

    // Calculate duration based on type
    int durationSeconds;
    switch (type) {
      case LessonType.quiz:
        // 30 seconds per question
        durationSeconds = map['duration'] as int? ?? ((questions?.length ?? 0) * 30);
        break;
      case LessonType.flashcard:
        // 10 seconds per card
        durationSeconds = map['duration'] as int? ?? ((cards?.length ?? 0) * 10);
        break;
      case LessonType.text:
        // Use estimatedReadTime or duration
        durationSeconds = map['estimatedReadTime'] as int? ?? map['duration'] as int? ?? 0;
        break;
      default:
        durationSeconds = map['duration'] as int? ?? 0;
    }

    return VideoModel(
      id: id,
      title: map['title'] as String? ?? '',
      type: type,
      category: map['category'] as String? ?? '',
      videoUrl: map['videoUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      sectionNumber: map['sectionNumber'] as int? ?? 0,
      rowNumber: (map['rowNumber'] ?? map['row']) as int? ?? 0,
      duration: Duration(seconds: durationSeconds),
      isPremium: map['isPremium'] as bool? ?? false,
      description: map['description'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      courseId: map['courseId'] as String?,
      // Audio
      audioUrl: map['audioUrl'] as String?,
      // Text
      content: map['content'] as String?,
      bannerUrl: map['banner_url'] as String?,
      estimatedReadTime: map['estimatedReadTime'] as int?,
      // Quiz
      questions: questions,
      passingPercentage: map['passingPercentage'] as int?,
      // Flashcard
      cards: cards,
      // Multi-language titles
      titleDe: map['title_de'] as String?,
      titleEs: map['title_es'] as String?,
      titleFr: map['title_fr'] as String?,
      titleJa: map['title_ja'] as String?,
      titleKo: map['title_ko'] as String?,
      titleZh: map['title_zh'] as String?,
      // Multi-language descriptions
      descriptionDe: map['description_de'] as String?,
      descriptionEs: map['description_es'] as String?,
      descriptionFr: map['description_fr'] as String?,
      descriptionJa: map['description_ja'] as String?,
      descriptionKo: map['description_ko'] as String?,
      descriptionZh: map['description_zh'] as String?,
      // Multi-language content
      contentDe: map['content_de'] as String?,
      contentEs: map['content_es'] as String?,
      contentFr: map['content_fr'] as String?,
      contentJa: map['content_ja'] as String?,
      contentKo: map['content_ko'] as String?,
      contentZh: map['content_zh'] as String?,
    );
  }

  /// Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'type': type.toFirestoreValue(),
      'sectionNumber': sectionNumber,
      'rowNumber': rowNumber,
      'row': rowNumber, // Keep both for backwards compatibility
      'duration': duration.inSeconds,
      'isPremium': isPremium,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };

    // Add optional common fields
    if (category.isNotEmpty) map['category'] = category;
    if (thumbnailUrl != null) map['thumbnailUrl'] = thumbnailUrl;
    if (description != null) map['description'] = description;
    if (tags.isNotEmpty) map['tags'] = tags;
    if (courseId != null) map['courseId'] = courseId;

    // Add type-specific fields
    switch (type) {
      case LessonType.video:
        if (videoUrl != null) map['videoUrl'] = videoUrl;
        break;
      case LessonType.audio:
        if (audioUrl != null) map['audioUrl'] = audioUrl;
        break;
      case LessonType.text:
        if (content != null) map['content'] = content;
        if (bannerUrl != null) map['banner_url'] = bannerUrl;
        if (estimatedReadTime != null) map['estimatedReadTime'] = estimatedReadTime;
        break;
      case LessonType.quiz:
        if (questions != null) {
          map['questions'] = questions!
              .map((q) => QuizQuestionModel.fromEntity(q).toMap())
              .toList();
        }
        if (passingPercentage != null) map['passingPercentage'] = passingPercentage;
        break;
      case LessonType.flashcard:
        if (cards != null) {
          map['cards'] = cards!
              .map((c) => FlashCardModel.fromEntity(c).toMap())
              .toList();
        }
        break;
    }

    // Add multi-language titles
    if (titleDe != null) map['title_de'] = titleDe;
    if (titleEs != null) map['title_es'] = titleEs;
    if (titleFr != null) map['title_fr'] = titleFr;
    if (titleJa != null) map['title_ja'] = titleJa;
    if (titleKo != null) map['title_ko'] = titleKo;
    if (titleZh != null) map['title_zh'] = titleZh;

    // Add multi-language descriptions
    if (descriptionDe != null) map['description_de'] = descriptionDe;
    if (descriptionEs != null) map['description_es'] = descriptionEs;
    if (descriptionFr != null) map['description_fr'] = descriptionFr;
    if (descriptionJa != null) map['description_ja'] = descriptionJa;
    if (descriptionKo != null) map['description_ko'] = descriptionKo;
    if (descriptionZh != null) map['description_zh'] = descriptionZh;

    // Add multi-language content (for text lessons)
    if (contentDe != null) map['content_de'] = contentDe;
    if (contentEs != null) map['content_es'] = contentEs;
    if (contentFr != null) map['content_fr'] = contentFr;
    if (contentJa != null) map['content_ja'] = contentJa;
    if (contentKo != null) map['content_ko'] = contentKo;
    if (contentZh != null) map['content_zh'] = contentZh;

    return map;
  }

  /// Convert to Map for Hive (local cache) - uses serializable types only
  Map<String, dynamic> toHiveMap() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'type': type.toFirestoreValue(),
      'category': category,
      'sectionNumber': sectionNumber,
      'rowNumber': rowNumber,
      'row': rowNumber,
      'duration': duration.inSeconds,
      'isPremium': isPremium,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

    // Add optional common fields
    if (thumbnailUrl != null) map['thumbnailUrl'] = thumbnailUrl;
    if (description != null) map['description'] = description;
    if (tags.isNotEmpty) map['tags'] = tags;
    if (courseId != null) map['courseId'] = courseId;

    // Add type-specific fields
    switch (type) {
      case LessonType.video:
        if (videoUrl != null) map['videoUrl'] = videoUrl;
        break;
      case LessonType.audio:
        if (audioUrl != null) map['audioUrl'] = audioUrl;
        break;
      case LessonType.text:
        if (content != null) map['content'] = content;
        if (bannerUrl != null) map['banner_url'] = bannerUrl;
        if (estimatedReadTime != null) map['estimatedReadTime'] = estimatedReadTime;
        break;
      case LessonType.quiz:
        if (questions != null) {
          map['questions'] = questions!
              .map((q) => QuizQuestionModel.fromEntity(q).toMap())
              .toList();
        }
        if (passingPercentage != null) map['passingPercentage'] = passingPercentage;
        break;
      case LessonType.flashcard:
        if (cards != null) {
          map['cards'] = cards!
              .map((c) => FlashCardModel.fromEntity(c).toMap())
              .toList();
        }
        break;
    }

    // Add multi-language titles
    if (titleDe != null) map['title_de'] = titleDe;
    if (titleEs != null) map['title_es'] = titleEs;
    if (titleFr != null) map['title_fr'] = titleFr;
    if (titleJa != null) map['title_ja'] = titleJa;
    if (titleKo != null) map['title_ko'] = titleKo;
    if (titleZh != null) map['title_zh'] = titleZh;

    // Add multi-language descriptions
    if (descriptionDe != null) map['description_de'] = descriptionDe;
    if (descriptionEs != null) map['description_es'] = descriptionEs;
    if (descriptionFr != null) map['description_fr'] = descriptionFr;
    if (descriptionJa != null) map['description_ja'] = descriptionJa;
    if (descriptionKo != null) map['description_ko'] = descriptionKo;
    if (descriptionZh != null) map['description_zh'] = descriptionZh;

    // Add multi-language content
    if (contentDe != null) map['content_de'] = contentDe;
    if (contentEs != null) map['content_es'] = contentEs;
    if (contentFr != null) map['content_fr'] = contentFr;
    if (contentJa != null) map['content_ja'] = contentJa;
    if (contentKo != null) map['content_ko'] = contentKo;
    if (contentZh != null) map['content_zh'] = contentZh;

    return map;
  }

  factory VideoModel.fromEntity(Video entity) {
    return VideoModel(
      id: entity.id,
      title: entity.title,
      type: entity.type,
      category: entity.category,
      videoUrl: entity.videoUrl,
      thumbnailUrl: entity.thumbnailUrl,
      sectionNumber: entity.sectionNumber,
      rowNumber: entity.rowNumber,
      duration: entity.duration,
      isPremium: entity.isPremium,
      description: entity.description,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      courseId: entity.courseId,
      audioUrl: entity.audioUrl,
      content: entity.content,
      bannerUrl: entity.bannerUrl,
      estimatedReadTime: entity.estimatedReadTime,
      questions: entity.questions,
      passingPercentage: entity.passingPercentage,
      cards: entity.cards,
      titleDe: entity.titleDe,
      titleEs: entity.titleEs,
      titleFr: entity.titleFr,
      titleJa: entity.titleJa,
      titleKo: entity.titleKo,
      titleZh: entity.titleZh,
      descriptionDe: entity.descriptionDe,
      descriptionEs: entity.descriptionEs,
      descriptionFr: entity.descriptionFr,
      descriptionJa: entity.descriptionJa,
      descriptionKo: entity.descriptionKo,
      descriptionZh: entity.descriptionZh,
      contentDe: entity.contentDe,
      contentEs: entity.contentEs,
      contentFr: entity.contentFr,
      contentJa: entity.contentJa,
      contentKo: entity.contentKo,
      contentZh: entity.contentZh,
    );
  }

  Video toEntity() {
    return Video(
      id: id,
      title: title,
      type: type,
      category: category,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      sectionNumber: sectionNumber,
      rowNumber: rowNumber,
      duration: duration,
      isPremium: isPremium,
      description: description,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      courseId: courseId,
      audioUrl: audioUrl,
      content: content,
      bannerUrl: bannerUrl,
      estimatedReadTime: estimatedReadTime,
      questions: questions,
      passingPercentage: passingPercentage,
      cards: cards,
      titleDe: titleDe,
      titleEs: titleEs,
      titleFr: titleFr,
      titleJa: titleJa,
      titleKo: titleKo,
      titleZh: titleZh,
      descriptionDe: descriptionDe,
      descriptionEs: descriptionEs,
      descriptionFr: descriptionFr,
      descriptionJa: descriptionJa,
      descriptionKo: descriptionKo,
      descriptionZh: descriptionZh,
      contentDe: contentDe,
      contentEs: contentEs,
      contentFr: contentFr,
      contentJa: contentJa,
      contentKo: contentKo,
      contentZh: contentZh,
    );
  }

  /// Create from video category data (legacy support)
  factory VideoModel.fromVideoData(
    Map<String, dynamic> categoryData,
    Map<String, dynamic> videoData,
  ) {
    final section = categoryData['section'] as int;
    final categoryTitle = categoryData['title'] as String;
    final row = videoData['row'] as int;
    final videoTitle = videoData['title'] as String;
    final isPremium = videoData['isPremium'] as bool? ?? false;
    final description = videoData['description'] as String?;

    return VideoModel(
      id: 'video_${section}_$row',
      title: videoTitle,
      type: LessonType.video,
      category: categoryTitle,
      videoUrl: 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_${section}_$row.mp4',
      sectionNumber: section,
      rowNumber: row,
      duration: const Duration(minutes: 10),
      isPremium: isPremium,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  VideoModel copyWith({
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
    return VideoModel(
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
}
