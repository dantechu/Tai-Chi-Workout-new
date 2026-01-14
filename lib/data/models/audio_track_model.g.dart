// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_track_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioTrackModel _$AudioTrackModelFromJson(Map<String, dynamic> json) =>
    AudioTrackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      type: $enumDecode(_$AudioTrackTypeEnumMap, json['type']),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      description: json['description'] as String?,
      artist: json['artist'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      locale: json['locale'] as String? ?? 'en',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AudioTrackModelToJson(AudioTrackModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'filePath': instance.filePath,
      'type': _$AudioTrackTypeEnumMap[instance.type]!,
      'duration': instance.duration.inMicroseconds,
      'description': instance.description,
      'artist': instance.artist,
      'thumbnailUrl': instance.thumbnailUrl,
      'isPremium': instance.isPremium,
      'locale': instance.locale,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AudioTrackTypeEnumMap = {
  AudioTrackType.music: 'music',
  AudioTrackType.voice: 'voice',
  AudioTrackType.sound: 'sound',
  AudioTrackType.breathing: 'breathing',
};
