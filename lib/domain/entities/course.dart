import 'package:equatable/equatable.dart';
import 'section.dart';

/// Domain entity representing a complete course
class Course extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final bool isDefault;
  final bool isFree;
  final int order;
  final String? thumbnailUrl;
  final List<Section> sections;
  final CourseMetadata metadata;
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

  const Course({
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

  /// Get localized name based on language code
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'de':
        return nameDe ?? name;
      case 'es':
        return nameEs ?? name;
      case 'fr':
        return nameFr ?? name;
      case 'ja':
        return nameJa ?? name;
      case 'ko':
        return nameKo ?? name;
      case 'zh':
        return nameZh ?? name;
      default:
        return name;
    }
  }

  /// Get localized description based on language code
  String getLocalizedDescription(String languageCode) {
    switch (languageCode) {
      case 'de':
        return descriptionDe ?? description;
      case 'es':
        return descriptionEs ?? description;
      case 'fr':
        return descriptionFr ?? description;
      case 'ja':
        return descriptionJa ?? description;
      case 'ko':
        return descriptionKo ?? description;
      case 'zh':
        return descriptionZh ?? description;
      default:
        return description;
    }
  }

  /// Get total number of videos across all sections
  int get totalVideos => sections.fold<int>(
        0,
        (sum, section) => sum + section.videos.length,
      );

  /// Get total duration of all videos
  Duration get totalDuration => sections.fold<Duration>(
        Duration.zero,
        (total, section) => total + section.totalDuration,
      );

  /// Get all videos from all sections in a flat list
  List<dynamic> get allVideos => sections
      .expand((section) => section.videos)
      .toList();

  /// Get only free videos
  List<dynamic> get freeVideos => allVideos
      .where((video) => !(video as dynamic).isPremium as bool)
      .toList();

  /// Get only premium videos
  List<dynamic> get premiumVideos => allVideos
      .where((video) => (video as dynamic).isPremium as bool)
      .toList();

  /// Check if course has any premium content
  bool get hasPremiumContent => premiumVideos.isNotEmpty;

  Course copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    bool? isDefault,
    bool? isFree,
    int? order,
    String? thumbnailUrl,
    List<Section>? sections,
    CourseMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nameDe,
    String? descriptionDe,
    String? nameEs,
    String? descriptionEs,
    String? nameFr,
    String? descriptionFr,
    String? nameJa,
    String? descriptionJa,
    String? nameKo,
    String? descriptionKo,
    String? nameZh,
    String? descriptionZh,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      isFree: isFree ?? this.isFree,
      order: order ?? this.order,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sections: sections ?? this.sections,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nameDe: nameDe ?? this.nameDe,
      descriptionDe: descriptionDe ?? this.descriptionDe,
      nameEs: nameEs ?? this.nameEs,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      nameFr: nameFr ?? this.nameFr,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      nameJa: nameJa ?? this.nameJa,
      descriptionJa: descriptionJa ?? this.descriptionJa,
      nameKo: nameKo ?? this.nameKo,
      descriptionKo: descriptionKo ?? this.descriptionKo,
      nameZh: nameZh ?? this.nameZh,
      descriptionZh: descriptionZh ?? this.descriptionZh,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        isActive,
        isDefault,
        isFree,
        order,
        thumbnailUrl,
        sections,
        metadata,
        createdAt,
        updatedAt,
        nameDe,
        descriptionDe,
        nameEs,
        descriptionEs,
        nameFr,
        descriptionFr,
        nameJa,
        descriptionJa,
        nameKo,
        descriptionKo,
        nameZh,
        descriptionZh,
      ];

  @override
  String toString() {
    return 'Course(id: $id, name: $name, sections: ${sections.length}, active: $isActive, default: $isDefault, free: $isFree)';
  }
}

/// Metadata about a course
class CourseMetadata extends Equatable {
  final int totalVideos;
  final int totalSections;
  final int totalDuration; // in seconds
  final int premiumVideos;
  final int freeVideos;

  const CourseMetadata({
    required this.totalVideos,
    required this.totalSections,
    required this.totalDuration,
    required this.premiumVideos,
    required this.freeVideos,
  });

  /// Get duration as Duration object
  Duration get duration => Duration(seconds: totalDuration);

  /// Format duration as human-readable string (e.g., "2h 30m")
  String get formattedDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  CourseMetadata copyWith({
    int? totalVideos,
    int? totalSections,
    int? totalDuration,
    int? premiumVideos,
    int? freeVideos,
  }) {
    return CourseMetadata(
      totalVideos: totalVideos ?? this.totalVideos,
      totalSections: totalSections ?? this.totalSections,
      totalDuration: totalDuration ?? this.totalDuration,
      premiumVideos: premiumVideos ?? this.premiumVideos,
      freeVideos: freeVideos ?? this.freeVideos,
    );
  }

  @override
  List<Object?> get props => [
        totalVideos,
        totalSections,
        totalDuration,
        premiumVideos,
        freeVideos,
      ];

  @override
  String toString() {
    return 'CourseMetadata(videos: $totalVideos, sections: $totalSections, duration: ${formattedDuration})';
  }
}
