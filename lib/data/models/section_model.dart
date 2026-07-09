import '../../domain/entities/section.dart';
import '../../domain/entities/lesson_type.dart';
import 'video_model.dart';

/// Data model for Section that handles Firestore serialization.
///
/// Supports both `lessons` and `videos` arrays for backward compatibility.
/// When reading, tries `lessons` first, then falls back to `videos`.
class SectionModel {
  final String id;
  final int sectionNumber;
  final String title;
  final String description;
  final int order;
  final List<VideoModel> videos;

  // Multi-language support fields
  final String? titleDe;
  final String? titleEs;
  final String? titleFr;
  final String? titleJa;
  final String? titleKo;
  final String? titleZh;

  const SectionModel({
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

  /// Create from Map (Firestore compatible)
  /// Tries 'lessons' array first, falls back to 'videos' for backward compatibility
  factory SectionModel.fromMap(Map<String, dynamic> map) {
    // Generate ID from section number if not provided
    final id = map['id'] as String? ?? 'section_${map['sectionNumber']}';

    // Try 'lessons' first, then fall back to 'videos' for backward compatibility
    List<dynamic>? lessonsData = map['lessons'] as List<dynamic>?;
    lessonsData ??= map['videos'] as List<dynamic>?;

    final videos = lessonsData
            ?.map((v) => VideoModel.fromMap(v as Map<String, dynamic>))
            .toList() ??
        [];

    return SectionModel(
      id: id,
      sectionNumber: map['sectionNumber'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      order: map['order'] as int? ?? 0,
      videos: videos,
      // Multi-language support
      titleDe: map['title_de'] as String?,
      titleEs: map['title_es'] as String?,
      titleFr: map['title_fr'] as String?,
      titleJa: map['title_ja'] as String?,
      titleKo: map['title_ko'] as String?,
      titleZh: map['title_zh'] as String?,
    );
  }

  /// Convert to Map for Firestore
  /// Stores lessons in BOTH 'lessons' and 'videos' arrays for backward compatibility
  Map<String, dynamic> toMap() {
    final videoMaps = videos.map((v) => v.toMap()).toList();

    return {
      'id': id,
      'sectionNumber': sectionNumber,
      'title': title,
      'description': description,
      'order': order,
      // Store in both arrays for backward compatibility
      'lessons': videoMaps,
      'videos': videoMaps,
      // Multi-language support
      if (titleDe != null) 'title_de': titleDe,
      if (titleEs != null) 'title_es': titleEs,
      if (titleFr != null) 'title_fr': titleFr,
      if (titleJa != null) 'title_ja': titleJa,
      if (titleKo != null) 'title_ko': titleKo,
      if (titleZh != null) 'title_zh': titleZh,
    };
  }

  /// Convert to Map for Hive (local cache) - uses serializable types only
  Map<String, dynamic> toHiveMap() {
    final videoMaps = videos.map((v) => v.toHiveMap()).toList();

    return {
      'id': id,
      'sectionNumber': sectionNumber,
      'title': title,
      'description': description,
      'order': order,
      // Store in both arrays for backward compatibility
      'lessons': videoMaps,
      'videos': videoMaps,
      // Multi-language support
      if (titleDe != null) 'title_de': titleDe,
      if (titleEs != null) 'title_es': titleEs,
      if (titleFr != null) 'title_fr': titleFr,
      if (titleJa != null) 'title_ja': titleJa,
      if (titleKo != null) 'title_ko': titleKo,
      if (titleZh != null) 'title_zh': titleZh,
    };
  }

  /// Convert to domain entity
  Section toEntity() {
    return Section(
      id: id,
      sectionNumber: sectionNumber,
      title: title,
      description: description,
      order: order,
      videos: videos.map((v) => v.toEntity()).toList(),
      // Multi-language support
      titleDe: titleDe,
      titleEs: titleEs,
      titleFr: titleFr,
      titleJa: titleJa,
      titleKo: titleKo,
      titleZh: titleZh,
    );
  }

  /// Create from domain entity
  factory SectionModel.fromEntity(Section section) {
    return SectionModel(
      id: section.id,
      sectionNumber: section.sectionNumber,
      title: section.title,
      description: section.description,
      order: section.order,
      videos: section.videos
          .map((v) => VideoModel.fromEntity(v))
          .toList(),
      // Multi-language support
      titleDe: section.titleDe,
      titleEs: section.titleEs,
      titleFr: section.titleFr,
      titleJa: section.titleJa,
      titleKo: section.titleKo,
      titleZh: section.titleZh,
    );
  }

  /// Get lessons filtered by type
  List<VideoModel> getLessonsByType(LessonType type) {
    return videos.where((v) => v.type == type).toList();
  }

  /// Get count of lessons by type
  int getLessonCountByType(LessonType type) {
    return videos.where((v) => v.type == type).length;
  }

  /// Get total lesson count
  int get lessonCount => videos.length;

  /// Get video lesson count
  int get videoCount => getLessonCountByType(LessonType.video);

  /// Get audio lesson count
  int get audioCount => getLessonCountByType(LessonType.audio);

  /// Get text lesson count
  int get textCount => getLessonCountByType(LessonType.text);

  /// Get quiz count
  int get quizCount => getLessonCountByType(LessonType.quiz);

  /// Get flashcard count
  int get flashcardCount => getLessonCountByType(LessonType.flashcard);

  SectionModel copyWith({
    String? id,
    int? sectionNumber,
    String? title,
    String? description,
    int? order,
    List<VideoModel>? videos,
    String? titleDe,
    String? titleEs,
    String? titleFr,
    String? titleJa,
    String? titleKo,
    String? titleZh,
  }) {
    return SectionModel(
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
}
