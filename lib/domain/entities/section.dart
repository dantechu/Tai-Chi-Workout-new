import 'package:equatable/equatable.dart';
import 'video.dart';

/// Domain entity representing a section within a course
class Section extends Equatable {
  final String id;
  final int sectionNumber;
  final String title;
  final String description;
  final int order;
  final List<Video> videos;

  // Multi-language support fields
  final String? titleDe;
  final String? titleEs;
  final String? titleFr;
  final String? titleJa;
  final String? titleKo;
  final String? titleZh;

  const Section({
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

  /// Get total duration of all videos in this section
  Duration get totalDuration {
    return videos.fold(
      Duration.zero,
      (total, video) => total + video.duration,
    );
  }

  /// Get video count
  int get videoCount => videos.length;

  /// Get premium video count
  int get premiumVideoCount => videos.where((video) => video.isPremium).length;

  /// Get free video count
  int get freeVideoCount => videos.where((video) => !video.isPremium).length;

  /// Check if section has any premium videos
  bool get hasAnyPremiumVideos => premiumVideoCount > 0;

  /// Check if all videos are premium
  bool get hasOnlyPremiumVideos => premiumVideoCount == videoCount && videoCount > 0;

  /// Check if all videos are free
  bool get hasOnlyFreeVideos => freeVideoCount == videoCount && videoCount > 0;

  /// Get free videos
  List<Video> get freeVideos => videos.where((video) => !video.isPremium).toList();

  /// Get premium videos
  List<Video> get premiumVideos => videos.where((video) => video.isPremium).toList();

  Section copyWith({
    String? id,
    int? sectionNumber,
    String? title,
    String? description,
    int? order,
    List<Video>? videos,
    String? titleDe,
    String? titleEs,
    String? titleFr,
    String? titleJa,
    String? titleKo,
    String? titleZh,
  }) {
    return Section(
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

  @override
  List<Object?> get props => [
        id,
        sectionNumber,
        title,
        description,
        order,
        videos,
        titleDe,
        titleEs,
        titleFr,
        titleJa,
        titleKo,
        titleZh,
      ];

  @override
  String toString() {
    return 'Section(id: $id, number: $sectionNumber, title: $title, videos: $videoCount)';
  }
}
