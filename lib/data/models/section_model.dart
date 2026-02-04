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

  const SectionModel({
    required this.id,
    required this.sectionNumber,
    required this.title,
    required this.description,
    required this.order,
    required this.videos,
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
    );
  }
}
