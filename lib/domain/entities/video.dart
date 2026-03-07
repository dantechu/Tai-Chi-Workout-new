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
  final String? courseId;

  // Multi-language support fields
  final String? titleDe;
  final String? descriptionDe;
  final String? titleEs;
  final String? descriptionEs;
  final String? titleFr;
  final String? descriptionFr;
  final String? titleJa;
  final String? descriptionJa;
  final String? titleKo;
  final String? descriptionKo;
  final String? titleZh;
  final String? descriptionZh;

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
    this.courseId,
    // Multi-language support
    this.titleDe,
    this.descriptionDe,
    this.titleEs,
    this.descriptionEs,
    this.titleFr,
    this.descriptionFr,
    this.titleJa,
    this.descriptionJa,
    this.titleKo,
    this.descriptionKo,
    this.titleZh,
    this.descriptionZh,
  });

  /// Get localized title based on language code
  String getLocalizedTitle(String languageCode) {
    switch (languageCode) {
      case 'de':
        return titleDe ?? title;
      case 'es':
        return titleEs ?? title;
      case 'fr':
        return titleFr ?? title;
      case 'ja':
        return titleJa ?? title;
      case 'ko':
        return titleKo ?? title;
      case 'zh':
        return titleZh ?? title;
      default:
        return title;
    }
  }

  /// Get localized description based on language code
  String? getLocalizedDescription(String languageCode) {
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
        courseId,
        titleDe,
        descriptionDe,
        titleEs,
        descriptionEs,
        titleFr,
        descriptionFr,
        titleJa,
        descriptionJa,
        titleKo,
        descriptionKo,
        titleZh,
        descriptionZh,
      ];

  @override
  String toString() {
    return 'Video(id: $id, title: $title, category: $category, duration: $duration, isPremium: $isPremium)';
  }
}