import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/video.dart';
import 'video_model.dart';

part 'lesson_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LessonModel extends Lesson {
  @override
  @JsonKey(fromJson: _videosFromJson, toJson: _videosToJson)
  final List<Video> videos;

  const LessonModel({
    required super.id,
    required super.title,
    required super.description,
    required this.videos,
    required super.order,
    required super.sectionNumber,
    super.thumbnailUrl,
    super.createdAt,
    super.updatedAt,
  }) : super(videos: videos);

  static List<Video> _videosFromJson(List<dynamic> json) {
    return json.map((e) => VideoModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  static List<Map<String, dynamic>> _videosToJson(List<Video> videos) {
    return videos.map((video) {
      if (video is VideoModel) {
        return video.toHiveMap();
      } else {
        return VideoModel.fromEntity(video).toHiveMap();
      }
    }).toList();
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) => _$LessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonModelToJson(this);

  factory LessonModel.fromEntity(Lesson entity) {
    return LessonModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      videos: entity.videos,
      order: entity.order,
      sectionNumber: entity.sectionNumber,
      thumbnailUrl: entity.thumbnailUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Lesson toEntity() {
    return Lesson(
      id: id,
      title: title,
      description: description,
      videos: videos,
      order: order,
      sectionNumber: sectionNumber,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory LessonModel.fromCategoryData(Map<String, dynamic> categoryData) {
    final section = categoryData['section'] as int;
    final categoryTitle = categoryData['title'] as String;
    final videosData = categoryData['videos'] as List<dynamic>;

    final videos = videosData.map((videoData) {
      return VideoModel.fromVideoData(categoryData, videoData as Map<String, dynamic>);
    }).toList();

    return LessonModel(
      id: section.toString(),
      title: categoryTitle,
      description: 'Tai Chi $categoryTitle lessons with John Saxxon',
      videos: videos.cast<Video>(),
      order: section,
      sectionNumber: section,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  LessonModel copyWith({
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
    return LessonModel(
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
}