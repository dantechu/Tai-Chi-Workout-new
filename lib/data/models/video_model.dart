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
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
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
    );
  }
}