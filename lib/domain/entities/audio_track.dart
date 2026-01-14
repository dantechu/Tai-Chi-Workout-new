import 'package:equatable/equatable.dart';

enum AudioTrackType {
  music,
  voice,
  sound,
  breathing,
}

class AudioTrack extends Equatable {
  final String id;
  final String title;
  final String filePath;
  final AudioTrackType type;
  final Duration duration;
  final String? description;
  final String? artist;
  final String? thumbnailUrl;
  final bool isPremium;
  final String locale;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AudioTrack({
    required this.id,
    required this.title,
    required this.filePath,
    required this.type,
    required this.duration,
    this.description,
    this.artist,
    this.thumbnailUrl,
    this.isPremium = false,
    this.locale = 'en',
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory AudioTrack.music({
    required String id,
    required String title,
    required String filePath,
    required Duration duration,
    String? description,
    String? artist,
    String? thumbnailUrl,
    bool isPremium = false,
    Map<String, dynamic>? metadata,
  }) {
    return AudioTrack(
      id: id,
      title: title,
      filePath: filePath,
      type: AudioTrackType.music,
      duration: duration,
      description: description,
      artist: artist,
      thumbnailUrl: thumbnailUrl,
      isPremium: isPremium,
      metadata: metadata,
    );
  }

  factory AudioTrack.voiceGuidance({
    required String id,
    required String title,
    required String filePath,
    required Duration duration,
    required String locale,
    String? description,
    bool isPremium = false,
    Map<String, dynamic>? metadata,
  }) {
    return AudioTrack(
      id: id,
      title: title,
      filePath: filePath,
      type: AudioTrackType.voice,
      duration: duration,
      description: description,
      locale: locale,
      isPremium: isPremium,
      metadata: metadata,
    );
  }

  factory AudioTrack.breathingSound({
    required String id,
    required String title,
    required String filePath,
    required Duration duration,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return AudioTrack(
      id: id,
      title: title,
      filePath: filePath,
      type: AudioTrackType.breathing,
      duration: duration,
      description: description,
      metadata: metadata,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case AudioTrackType.music:
        return 'Music';
      case AudioTrackType.voice:
        return 'Voice Guidance';
      case AudioTrackType.sound:
        return 'Sound Effect';
      case AudioTrackType.breathing:
        return 'Breathing Sound';
    }
  }

  bool get isLocalAsset => filePath.startsWith('assets/');

  bool get isNetworkUrl => filePath.startsWith('http');

  String get displayTitle {
    if (artist != null && artist!.isNotEmpty) {
      return '$title - $artist';
    }
    return title;
  }

  AudioTrack copyWith({
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
    return AudioTrack(
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

  @override
  List<Object?> get props => [
        id,
        title,
        filePath,
        type,
        duration,
        description,
        artist,
        thumbnailUrl,
        isPremium,
        locale,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'AudioTrack(id: $id, title: $title, type: $type, duration: $duration, locale: $locale)';
  }
}