import '../../domain/entities/section.dart';
import 'video_model.dart';

/// Data model for Section that handles Firestore serialization
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

  /// Create from Map
  factory SectionModel.fromMap(Map<String, dynamic> map) {
    // Generate ID from section number if not provided
    final id = map['id'] as String? ?? 'section_${map['sectionNumber']}';

    return SectionModel(
      id: id,
      sectionNumber: map['sectionNumber'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      order: map['order'] as int? ?? 0,
      videos: (map['videos'] as List<dynamic>?)
              ?.map((v) => VideoModel.fromMap(v as Map<String, dynamic>))
              .toList() ??
          [],
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
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sectionNumber': sectionNumber,
      'title': title,
      'description': description,
      'order': order,
      'videos': videos.map((v) => v.toMap()).toList(),
      // Multi-language support
      'title_de': titleDe,
      'title_es': titleEs,
      'title_fr': titleFr,
      'title_ja': titleJa,
      'title_ko': titleKo,
      'title_zh': titleZh,
    };
  }

  /// Convert to Map for Hive (local cache) - uses serializable types only
  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'sectionNumber': sectionNumber,
      'title': title,
      'description': description,
      'order': order,
      'videos': videos.map((v) => v.toHiveMap()).toList(),
      // Multi-language support
      'title_de': titleDe,
      'title_es': titleEs,
      'title_fr': titleFr,
      'title_ja': titleJa,
      'title_ko': titleKo,
      'title_zh': titleZh,
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
}
