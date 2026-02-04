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
  });

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
