import 'package:equatable/equatable.dart';
import 'video.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<Video> videos;
  final int order;
  final int sectionNumber;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.videos,
    required this.order,
    required this.sectionNumber,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  Duration get totalDuration {
    return videos.fold(
      Duration.zero,
      (total, video) => total + video.duration,
    );
  }

  int get videoCount => videos.length;

  int get premiumVideoCount => videos.where((video) => video.isPremium).length;

  int get freeVideoCount => videos.where((video) => !video.isPremium).length;

  bool get hasAnyPremiumVideos => premiumVideoCount > 0;

  bool get hasOnlyPremiumVideos => premiumVideoCount == videoCount;

  List<Video> get freeVideos => videos.where((video) => !video.isPremium).toList();

  List<Video> get premiumVideos => videos.where((video) => video.isPremium).toList();

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    List<Video>? videos,
    int? order,
    int? sectionNumber,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videos: videos ?? this.videos,
      order: order ?? this.order,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        videos,
        order,
        sectionNumber,
        thumbnailUrl,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Lesson(id: $id, title: $title, videoCount: $videoCount, duration: $totalDuration)';
  }
}