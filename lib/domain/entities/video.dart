import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String title;
  final String category;
  final String videoUrl;
  final String? thumbnailUrl;
  final int sectionNumber;
  final int rowNumber;
  final Duration duration;
  final bool isPremium;
  final String? description;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Video({
    required this.id,
    required this.title,
    required this.category,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.sectionNumber,
    required this.rowNumber,
    required this.duration,
    this.isPremium = false,
    this.description,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  Video copyWith({
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
    return Video(
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

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        videoUrl,
        thumbnailUrl,
        sectionNumber,
        rowNumber,
        duration,
        isPremium,
        description,
        tags,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Video(id: $id, title: $title, category: $category, duration: $duration, isPremium: $isPremium)';
  }
}