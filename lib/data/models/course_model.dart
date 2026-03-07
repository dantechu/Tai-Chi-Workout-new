import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/course.dart';
import 'section_model.dart';

/// Data model for Course that handles Firestore serialization
class CourseModel {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final bool isDefault;
  final bool isFree;
  final int order;
  final String? thumbnailUrl;
  final List<SectionModel> sections;
  final CourseMetadataModel metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Multi-language support fields
  final String? nameDe;
  final String? descriptionDe;
  final String? nameEs;
  final String? descriptionEs;
  final String? nameFr;
  final String? descriptionFr;
  final String? nameJa;
  final String? descriptionJa;
  final String? nameKo;
  final String? descriptionKo;
  final String? nameZh;
  final String? descriptionZh;

  const CourseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.isDefault,
    required this.isFree,
    required this.order,
    this.thumbnailUrl,
    required this.sections,
    required this.metadata,
    this.createdAt,
    this.updatedAt,
    // Multi-language support
    this.nameDe,
    this.descriptionDe,
    this.nameEs,
    this.descriptionEs,
    this.nameFr,
    this.descriptionFr,
    this.nameJa,
    this.descriptionJa,
    this.nameKo,
    this.descriptionKo,
    this.nameZh,
    this.descriptionZh,
  });

  /// Create from Firestore DocumentSnapshot
  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel.fromMap(data, doc.id);
  }

  /// Create from Map
  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? false,
      isDefault: map['isDefault'] as bool? ?? false,
      isFree: map['isFree'] as bool? ?? false,
      order: map['order'] as int? ?? 0,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      sections: (map['sections'] as List<dynamic>?)
              ?.map((s) => SectionModel.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: map['metadata'] != null
          ? CourseMetadataModel.fromMap(map['metadata'] as Map<String, dynamic>)
          : const CourseMetadataModel(
              totalVideos: 0,
              totalSections: 0,
              totalDuration: 0,
              premiumVideos: 0,
              freeVideos: 0,
            ),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      // Multi-language support
      nameDe: map['name_de'] as String?,
      descriptionDe: map['description_de'] as String?,
      nameEs: map['name_es'] as String?,
      descriptionEs: map['description_es'] as String?,
      nameFr: map['name_fr'] as String?,
      descriptionFr: map['description_fr'] as String?,
      nameJa: map['name_ja'] as String?,
      descriptionJa: map['description_ja'] as String?,
      nameKo: map['name_ko'] as String?,
      descriptionKo: map['description_ko'] as String?,
      nameZh: map['name_zh'] as String?,
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

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
      'isDefault': isDefault,
      'isFree': isFree,
      'order': order,
      'thumbnailUrl': thumbnailUrl,
      'sections': sections.map((s) => s.toMap()).toList(),
      'metadata': metadata.toMap(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      // Multi-language support
      'name_de': nameDe,
      'description_de': descriptionDe,
      'name_es': nameEs,
      'description_es': descriptionEs,
      'name_fr': nameFr,
      'description_fr': descriptionFr,
      'name_ja': nameJa,
      'description_ja': descriptionJa,
      'name_ko': nameKo,
      'description_ko': descriptionKo,
      'name_zh': nameZh,
      'description_zh': descriptionZh,
    };
  }

  /// Convert to Map for Hive (local cache) - uses serializable types only
  Map<String, dynamic> toHiveMap() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
      'isDefault': isDefault,
      'isFree': isFree,
      'order': order,
      'thumbnailUrl': thumbnailUrl,
      'sections': sections.map((s) => s.toHiveMap()).toList(),
      'metadata': metadata.toMap(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      // Multi-language support
      'name_de': nameDe,
      'description_de': descriptionDe,
      'name_es': nameEs,
      'description_es': descriptionEs,
      'name_fr': nameFr,
      'description_fr': descriptionFr,
      'name_ja': nameJa,
      'description_ja': descriptionJa,
      'name_ko': nameKo,
      'description_ko': descriptionKo,
      'name_zh': nameZh,
      'description_zh': descriptionZh,
    };
  }

  /// Convert to domain entity
  Course toEntity() {
    return Course(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      isDefault: isDefault,
      isFree: isFree,
      order: order,
      thumbnailUrl: thumbnailUrl,
      sections: sections.map((s) => s.toEntity()).toList(),
      metadata: metadata.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      // Multi-language support
      nameDe: nameDe,
      descriptionDe: descriptionDe,
      nameEs: nameEs,
      descriptionEs: descriptionEs,
      nameFr: nameFr,
      descriptionFr: descriptionFr,
      nameJa: nameJa,
      descriptionJa: descriptionJa,
      nameKo: nameKo,
      descriptionKo: descriptionKo,
      nameZh: nameZh,
      descriptionZh: descriptionZh,
    );
  }

  /// Create from domain entity
  factory CourseModel.fromEntity(Course course) {
    return CourseModel(
      id: course.id,
      name: course.name,
      description: course.description,
      isActive: course.isActive,
      isDefault: course.isDefault,
      isFree: course.isFree,
      order: course.order,
      thumbnailUrl: course.thumbnailUrl,
      sections: course.sections
          .map((s) => SectionModel.fromEntity(s))
          .toList(),
      metadata: CourseMetadataModel.fromEntity(course.metadata),
      createdAt: course.createdAt,
      updatedAt: course.updatedAt,
      // Multi-language support
      nameDe: course.nameDe,
      descriptionDe: course.descriptionDe,
      nameEs: course.nameEs,
      descriptionEs: course.descriptionEs,
      nameFr: course.nameFr,
      descriptionFr: course.descriptionFr,
      nameJa: course.nameJa,
      descriptionJa: course.descriptionJa,
      nameKo: course.nameKo,
      descriptionKo: course.descriptionKo,
      nameZh: course.nameZh,
      descriptionZh: course.descriptionZh,
    );
  }
}

/// Data model for CourseMetadata
class CourseMetadataModel {
  final int totalVideos;
  final int totalSections;
  final int totalDuration;
  final int premiumVideos;
  final int freeVideos;

  const CourseMetadataModel({
    required this.totalVideos,
    required this.totalSections,
    required this.totalDuration,
    required this.premiumVideos,
    required this.freeVideos,
  });

  factory CourseMetadataModel.fromMap(Map<String, dynamic> map) {
    return CourseMetadataModel(
      totalVideos: map['totalVideos'] as int? ?? 0,
      totalSections: map['totalSections'] as int? ?? 0,
      totalDuration: map['totalDuration'] as int? ?? 0,
      premiumVideos: map['premiumVideos'] as int? ?? 0,
      freeVideos: map['freeVideos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalVideos': totalVideos,
      'totalSections': totalSections,
      'totalDuration': totalDuration,
      'premiumVideos': premiumVideos,
      'freeVideos': freeVideos,
    };
  }

  CourseMetadata toEntity() {
    return CourseMetadata(
      totalVideos: totalVideos,
      totalSections: totalSections,
      totalDuration: totalDuration,
      premiumVideos: premiumVideos,
      freeVideos: freeVideos,
    );
  }

  factory CourseMetadataModel.fromEntity(CourseMetadata metadata) {
    return CourseMetadataModel(
      totalVideos: metadata.totalVideos,
      totalSections: metadata.totalSections,
      totalDuration: metadata.totalDuration,
      premiumVideos: metadata.premiumVideos,
      freeVideos: metadata.freeVideos,
    );
  }
}
