import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/video.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    required super.category,
    required super.videoUrl,
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
    // Multi-language support
    super.titleDe,
    super.descriptionDe,
    super.titleEs,
    super.descriptionEs,
    super.titleFr,
    super.descriptionFr,
    super.titleJa,
    super.descriptionJa,
    super.titleKo,
    super.descriptionKo,
    super.titleZh,
    super.descriptionZh,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  /// Create from Map (Firestore compatible)
  factory VideoModel.fromMap(Map<String, dynamic> map) {
    // Generate ID from section and row if not provided
    final id = map['id'] as String? ??
        'video_${map['sectionNumber']}_${map['rowNumber'] ?? map['row']}';

    return VideoModel(
      id: id,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String?,
      sectionNumber: map['sectionNumber'] as int? ?? 0,
      rowNumber: (map['rowNumber'] ?? map['row']) as int? ?? 0,
      duration: Duration(seconds: map['duration'] as int? ?? 0),
      isPremium: map['isPremium'] as bool? ?? false,
      description: map['description'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      courseId: map['courseId'] as String?,
      // Multi-language support
      titleDe: map['title_de'] as String?,
      descriptionDe: map['description_de'] as String?,
      titleEs: map['title_es'] as String?,
      descriptionEs: map['description_es'] as String?,
      titleFr: map['title_fr'] as String?,
      descriptionFr: map['description_fr'] as String?,
      titleJa: map['title_ja'] as String?,
      descriptionJa: map['description_ja'] as String?,
      titleKo: map['title_ko'] as String?,
      descriptionKo: map['description_ko'] as String?,
      titleZh: map['title_zh'] as String?,
      descriptionZh: map['description_zh'] as String?,
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

  /// Convert to Map (Firestore compatible)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'sectionNumber': sectionNumber,
      'rowNumber': rowNumber,
      'row': rowNumber, // Keep both for backwards compatibility
      'duration': duration.inSeconds,
      'isPremium': isPremium,
      'description': description,
      'tags': tags,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'courseId': courseId,
      // Multi-language support
      'title_de': titleDe,
      'description_de': descriptionDe,
      'title_es': titleEs,
      'description_es': descriptionEs,
      'title_fr': titleFr,
      'description_fr': descriptionFr,
      'title_ja': titleJa,
      'description_ja': descriptionJa,
      'title_ko': titleKo,
      'description_ko': descriptionKo,
      'title_zh': titleZh,
      'description_zh': descriptionZh,
    };
  }

  /// Convert to Map for Hive (local cache) - uses serializable types only
  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'sectionNumber': sectionNumber,
      'rowNumber': rowNumber,
      'row': rowNumber, // Keep both for backwards compatibility
      'duration': duration.inSeconds,
      'isPremium': isPremium,
      'description': description,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'courseId': courseId,
      // Multi-language support
      'title_de': titleDe,
      'description_de': descriptionDe,
      'title_es': titleEs,
      'description_es': descriptionEs,
      'title_fr': titleFr,
      'description_fr': descriptionFr,
      'title_ja': titleJa,
      'description_ja': descriptionJa,
      'title_ko': titleKo,
      'description_ko': descriptionKo,
      'title_zh': titleZh,
      'description_zh': descriptionZh,
    };
  }

  factory VideoModel.fromEntity(Video entity) {
    return VideoModel(
      id: entity.id,
      title: entity.title,
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
      // Multi-language support
      titleDe: entity.titleDe,
      descriptionDe: entity.descriptionDe,
      titleEs: entity.titleEs,
      descriptionEs: entity.descriptionEs,
      titleFr: entity.titleFr,
      descriptionFr: entity.descriptionFr,
      titleJa: entity.titleJa,
      descriptionJa: entity.descriptionJa,
      titleKo: entity.titleKo,
      descriptionKo: entity.descriptionKo,
      titleZh: entity.titleZh,
      descriptionZh: entity.descriptionZh,
    );
  }

  Video toEntity() {
    return Video(
      id: id,
      title: title,
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
      // Multi-language support
      titleDe: titleDe,
      descriptionDe: descriptionDe,
      titleEs: titleEs,
      descriptionEs: descriptionEs,
      titleFr: titleFr,
      descriptionFr: descriptionFr,
      titleJa: titleJa,
      descriptionJa: descriptionJa,
      titleKo: titleKo,
      descriptionKo: descriptionKo,
      titleZh: titleZh,
      descriptionZh: descriptionZh,
    );
  }

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
      id: '${section}_$row',
      title: videoTitle,
      category: categoryTitle,
      videoUrl: 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_${section}_$row.mp4',
      sectionNumber: section,
      rowNumber: row,
      duration: const Duration(minutes: 10), // Default duration
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
    String? titleDe,
    String? descriptionDe,
    String? titleEs,
    String? descriptionEs,
    String? titleFr,
    String? descriptionFr,
    String? titleJa,
    String? descriptionJa,
    String? titleKo,
    String? descriptionKo,
    String? titleZh,
    String? descriptionZh,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
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
      titleDe: titleDe ?? this.titleDe,
      descriptionDe: descriptionDe ?? this.descriptionDe,
      titleEs: titleEs ?? this.titleEs,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      titleFr: titleFr ?? this.titleFr,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      titleJa: titleJa ?? this.titleJa,
      descriptionJa: descriptionJa ?? this.descriptionJa,
      titleKo: titleKo ?? this.titleKo,
      descriptionKo: descriptionKo ?? this.descriptionKo,
      titleZh: titleZh ?? this.titleZh,
      descriptionZh: descriptionZh ?? this.descriptionZh,
    );
  }
}