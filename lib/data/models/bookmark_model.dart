import '../../domain/entities/bookmark.dart';

class BookmarkModel extends Bookmark {
  const BookmarkModel({
    required super.id,
    required super.videoId,
    required super.createdAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookmarkModel.fromEntity(Bookmark entity) {
    return BookmarkModel(
      id: entity.id,
      videoId: entity.videoId,
      createdAt: entity.createdAt,
    );
  }

  factory BookmarkModel.create(String videoId) {
    return BookmarkModel(
      id: '${videoId}_${DateTime.now().millisecondsSinceEpoch}',
      videoId: videoId,
      createdAt: DateTime.now(),
    );
  }

  Bookmark toEntity() {
    return Bookmark(
      id: id,
      videoId: videoId,
      createdAt: createdAt,
    );
  }
}
