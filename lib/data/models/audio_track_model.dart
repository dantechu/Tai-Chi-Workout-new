import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/audio_track.dart';

part 'audio_track_model.g.dart';

@JsonSerializable()
class AudioTrackModel extends AudioTrack {
  const AudioTrackModel({
    required super.id,
    required super.title,
    required super.filePath,
    required super.type,
    required super.duration,
    super.description,
    super.artist,
    super.thumbnailUrl,
    super.isPremium = false,
    super.locale = 'en',
    super.metadata,
    super.createdAt,
    super.updatedAt,
  });

  factory AudioTrackModel.fromJson(Map<String, dynamic> json) => 
      _$AudioTrackModelFromJson(json);

  Map<String, dynamic> toJson() => _$AudioTrackModelToJson(this);

  factory AudioTrackModel.fromEntity(AudioTrack entity) {
    return AudioTrackModel(
      id: entity.id,
      title: entity.title,
      filePath: entity.filePath,
      type: entity.type,
      duration: entity.duration,
      description: entity.description,
      artist: entity.artist,
      thumbnailUrl: entity.thumbnailUrl,
      isPremium: entity.isPremium,
      locale: entity.locale,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  AudioTrack toEntity() {
    return AudioTrack(
      id: id,
      title: title,
      filePath: filePath,
      type: type,
      duration: duration,
      description: description,
      artist: artist,
      thumbnailUrl: thumbnailUrl,
      isPremium: isPremium,
      locale: locale,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  AudioTrackModel copyWith({
    String? id,
    String? title,
    String? filePath,
    AudioTrackType? type,
    Duration? duration,
    String? description,
    String? artist,
    String? thumbnailUrl,
    bool? isPremium,
    String? locale,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AudioTrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      artist: artist ?? this.artist,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPremium: isPremium ?? this.isPremium,
      locale: locale ?? this.locale,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}