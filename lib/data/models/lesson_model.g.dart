// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonModel _$LessonModelFromJson(Map<String, dynamic> json) => LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videos: LessonModel._videosFromJson(json['videos'] as List),
      order: (json['order'] as num).toInt(),
      sectionNumber: (json['sectionNumber'] as num).toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LessonModelToJson(LessonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'order': instance.order,
      'sectionNumber': instance.sectionNumber,
      'thumbnailUrl': instance.thumbnailUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'videos': LessonModel._videosToJson(instance.videos),
    };
