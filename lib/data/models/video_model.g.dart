// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      sectionNumber: (json['sectionNumber'] as num).toInt(),
      rowNumber: (json['rowNumber'] as num).toInt(),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      isPremium: json['isPremium'] as bool? ?? false,
      description: json['description'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      courseId: json['courseId'] as String?,
      titleDe: json['titleDe'] as String?,
      descriptionDe: json['descriptionDe'] as String?,
      titleEs: json['titleEs'] as String?,
      descriptionEs: json['descriptionEs'] as String?,
      titleFr: json['titleFr'] as String?,
      descriptionFr: json['descriptionFr'] as String?,
      titleJa: json['titleJa'] as String?,
      descriptionJa: json['descriptionJa'] as String?,
      titleKo: json['titleKo'] as String?,
      descriptionKo: json['descriptionKo'] as String?,
      titleZh: json['titleZh'] as String?,
      descriptionZh: json['descriptionZh'] as String?,
    );

Map<String, dynamic> _$VideoModelToJson(VideoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'sectionNumber': instance.sectionNumber,
      'rowNumber': instance.rowNumber,
      'duration': instance.duration.inMicroseconds,
      'isPremium': instance.isPremium,
      'description': instance.description,
      'tags': instance.tags,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'courseId': instance.courseId,
      'titleDe': instance.titleDe,
      'descriptionDe': instance.descriptionDe,
      'titleEs': instance.titleEs,
      'descriptionEs': instance.descriptionEs,
      'titleFr': instance.titleFr,
      'descriptionFr': instance.descriptionFr,
      'titleJa': instance.titleJa,
      'descriptionJa': instance.descriptionJa,
      'titleKo': instance.titleKo,
      'descriptionKo': instance.descriptionKo,
      'titleZh': instance.titleZh,
      'descriptionZh': instance.descriptionZh,
    };
